# powershell

PowerShell profile for this dotfiles repo: an [oh-my-posh](https://ohmyposh.dev)
prompt that mirrors the zsh theme, a small module starter pack, PSReadLine
syntax colors and inline predictions, and **base16 theming that follows the same
theme the zsh side selects**.

## What's here

| File | Purpose |
| --- | --- |
| `config/powershell/profile.ps1.symlink` | The profile. Symlinked in as `profile.ps1` (the all-hosts profile) on both WSL and Windows. |
| `base16.ps1` | base16 loader, auto-loaded as a topical fragment. Re-emits the shared `base16-shell/` themes as OSC sequences. |
| `niander.omp.json` | oh-my-posh theme (uses ANSI color names so it recolors with base16). |
| `install.ps1` | Installs oh-my-posh + modules (cross-platform, idempotent; run by `script/install.ps1`). |

## Profile behavior

`config/powershell/profile.ps1.symlink` owns the shell-wide load order:

1. Run each topic's `path.ps1`.
2. Normalize, deduplicate, and prepend the declared paths.
3. Import `CompletionPredictor` and configure PSReadLine (keys, predictions, and
   syntax colors).
4. Dot-source the other top-level `topic/*.ps1` fragments.
5. Initialize oh-my-posh and source `~/.localprofile.ps1`.

The profile skips `install.ps1` files and everything under `script/`.

Path fragments affect only the current PowerShell process. Installers remain
responsible for persistent User or Machine PATH changes; the profile declarations
guarantee interactive shell behavior across Windows, Linux, and WSL.

Reload the complete profile state in the current session with `reload!`. It is
an `Invoke-Command -NoNewScope` alias configured through
`$PSDefaultParameterValues`.

## Topic-owned PowerShell configuration

The profile discovers these runtime fragments from their topic folders. Add
new topic behavior to this table instead of extending the profile description.

| Topic | Runtime fragments | Behavior |
| --- | --- | --- |
| `powershell/` | `base16.ps1`, `devdrive.ps1` | Defines the base16 commands, applies the shared theme, and maps `devfs:` to a ReFS `D:\` volume on Windows. The prompt displays that volume as `devfs:`. See [Topic details: base16 theming](#topic-details-base16-theming). |
| `system/` | `path.ps1`, `aliases.ps1` | Adds `~/.local/bin`; defines `l`/`la`/`ll`/`lt`/`lr` fallbacks with `Get-ChildItem` and `$PSStyle.FileInfo` colors. |
| `rust/` | `path.ps1` | Adds `~/.cargo/bin`. |
| `eza/` | `_eza.ps1`, `aliases.ps1` | Registers eza completion and replaces the listing helpers when eza is installed; adds `ltree`. Bare `ls` stays native. |
| `gh/` | `_gh.ps1` | Registers GitHub CLI completion. |
| `git/` | `aliases.ps1` | Loads `git-aliases`, restores PowerShell's built-ins, and loads `posh-git` on the first Git completion request. See [Topic details: git aliases](#topic-details-git-aliases). |
| `fzf/` | `config.ps1` | Loads `PSFzf` on the first `Ctrl+T` or `Ctrl+R`. |
| `miniconda/` | `conda.ps1` | Initializes the conda shell hook when conda is installed. |

## Linux / WSL (PowerShell 7)

`script/bootstrap` symlinks the profile in as `~/.config/powershell/profile.ps1`.
Install the PowerShell tooling with `pwsh script/install.ps1` (cross-platform),
then open a new `pwsh` session.

## Windows

Run the PowerShell bootstrap from a **PowerShell 7** window with **Developer
Mode on** (Settings > System > For developers) or an **elevated** shell — that's
needed to create the `~/.dotfiles` symlink:

```powershell
git clone https://github.com/niander/my-dotfiles.git
cd my-dotfiles
.\script\bootstrap.ps1
```

It symlinks `~/.dotfiles` to the checkout, symlinks your **all-hosts**
`profile.ps1` to this repo's profile (same as WSL; any existing `profile.ps1` is
backed up), wires up the git config (see below), and runs `script\install.ps1`
(Node.js LTS with npm, standalone pnpm, shell tools and the module starter
pack). Open a new PowerShell 7 window afterward.

Notes:
- PowerShell modules are installed under `~/PowerShell/Modules`, outside a
  redirected or OneDrive-backed Documents folder. The installer adds this as
  the current-user `PSModulePath` in `powershell.config.json` when the setting
  is absent. If that file already defines a different `PSModulePath`, module
  installation stops rather than overwriting the machine's configuration.
- The links (`~/.dotfiles`, `profile.ps1` and `~/.gitignore`) are real
  **symbolic links**; if Windows can't create one (no Developer Mode and not
  elevated), bootstrap fails with the exception rather than falling back.
- It links the **all-hosts** profile (`profile.ps1` = `$PROFILE.CurrentUserAllHosts`),
  so it loads in every host (console, VS Code, ...) and leaves the host profile
  (`Microsoft.PowerShell_profile.ps1`) untouched — that's where host-specific
  completers and tools live.
- Any existing `profile.ps1` is moved to `profile.ps1.backup`. Put machine-
  specific lines in `~/.localprofile.ps1` (the profile sources it) — conda now
  loads automatically via the `miniconda/` topic, so you usually won't need to.
- Only **PowerShell 7** is wired; Windows PowerShell 5.1 is left alone.
- base16 **theme scripts** are installed, so `base16 <name>` and
  tab-completion work; but auto-applying a theme on startup only happens when
  the shared enable flag exists (normally toggled from zsh), so on a
  Windows-only host apply one manually with `base16 <name>`.
- If scripts are blocked by execution policy, run
  `powershell -ExecutionPolicy Bypass -File .\script\bootstrap.ps1` (or
  `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`).

> `niander.omp.json` uses the oh-my-posh v3 config schema, so a current
> oh-my-posh is required; `winget install` provides one.

## Topic details: base16 theming

base16 themes recolor the terminal by emitting OSC escape sequences at runtime,
not by editing terminal config. `base16.ps1` reuses the exact `base16-*.sh`
definitions from the [`base16-shell/`](../base16-shell) topic — one source of
truth for both shells. Those definitions are a tinted-shell clone, fetched by
`script/install` (bash) on Linux/WSL or `script/install.ps1` (cross-platform)
on any host, so the themes are present on Windows too.

On load the profile auto-applies a theme **when**:

1. the shared enable flag `base16-shell/.base16_enabled` exists (toggle it from
   zsh with `base16 on` / `base16 off`), **and**
2. the terminal honors OSC palette sequences (Windows Terminal, ConEmu/Cmder,
   Windows 11 conhost, or a *nix terminal). GUI terminals that manage their own
   colors (VS Code) and legacy conhost are skipped.

It follows `~/.base16_theme` (the pointer the zsh side maintains), so PowerShell
shows whatever theme you last picked in zsh. Falls back to `eighties`.

Palette slots 16-21 follow the shared `base16 256 on`/`off` toggle: off (the
default) keeps index 16 black so TUIs stay readable; on emits the theme's base09
orange there. PowerShell and zsh read the same state.

Switch live in a session:

```powershell
Set-Base16Theme gruvbox-dark-hard   # alias: base16 gruvbox-dark-hard  (tab-completes)
Set-Base16ColorSpace on             # use theme colors for slots 16-21
Set-Base16ColorSpace off            # restore the xterm defaults
Get-Base16ColorSpace
base16 256 on                       # use theme colors for slots 16-21
base16 256 off                      # restore the xterm defaults
base16 256 status
Get-Base16Theme                     # list available themes
```

Set `$env:BASE16_SHELL_SET_BACKGROUND = 'false'` before load to keep your
terminal's own background (matches base16-shell's option of the same name).

## Windows git config

`script/bootstrap.ps1` writes the same `~/.gitconfig` include the bash bootstrap does
(see the root `README.md`), and symlinks `~/.gitconfig.dotfiles` plus `~/.gitignore`
for `core.excludesfile`. Re-running is a no-op.

Shared settings belong in `git/gitconfig.dotfiles.symlink`.
Private ones go in `~/.gitconfig`, which includes that baseline on its first two lines and overrides everything below.
`~/.gitconfig.local` is included by the baseline, so the baseline's own `[user]` section still wins over it.
`core.symlinks` is set there because the Git for Windows installer leaves
symlink support off by default.

Git Credential Manager answers for every host except GitHub, which `gh`
handles. See the `gh/` topic.

`core.autocrlf = input` keeps files LF in the working tree, overriding the
installer default of `true`, so a checkout stays consistent when shared with
WSL.

## Topic details: git aliases

The `git-aliases` module ports oh-my-zsh-style git shortcuts (`gst`, `gco`,
`gaa`, ...) to PowerShell. It also **strips several built-in aliases** — `gc`,
`gcb`, `gcm`, `gcs`, `gl`, `gm`, `gp`, `gpv` — replacing them with git functions,
and it does so whenever it auto-loads (on first use of any of its commands), so a
one-off `Set-Alias` won't hold.

`git/aliases.ps1` imports the module, keeps selected git functions under new
names, and restores the built-ins (`gc` → `Get-Content`, `gl` →
`Get-Location`, ...). The three most useful displaced shortcuts are:

| Shortcut | Runs |
| --- | --- |
| `gpull` | `git pull` (was `gl`) |
| `gcmain` | `git checkout <main branch>` (was `gcm`) |
| `gpush` | `git push` (was `gp`) |

All the non-conflicting git shortcuts (`gst`, `gco`, `gaa`, ...) keep working. To
change which built-ins are restored or add more renames, edit the two maps in
`git/aliases.ps1`.

## Local overrides

Machine-specific PowerShell lives in `~/.localprofile.ps1` (dot-sourced last if
present) — the PowerShell analogue of `~/.localrc`. Keep it out of the repo.
