# powershell

PowerShell profile for this dotfiles repo: an [oh-my-posh](https://ohmyposh.dev)
prompt that mirrors the zsh theme, a small module starter pack, PSReadLine
inline predictions, and **base16 theming that follows the same theme the zsh
side selects**.

## What's here

| File | Purpose |
| --- | --- |
| `config/powershell/profile.ps1.symlink` | The profile. Symlinked in as `profile.ps1` (the all-hosts profile) on both WSL and Windows. |
| `base16.ps1` | base16 loader, auto-loaded as a topical fragment. Re-emits the shared `base16-shell/` themes as OSC sequences. |
| `niander.omp.json` | oh-my-posh theme (uses ANSI color names so it recolors with base16). |
| `install.ps1` | Installs oh-my-posh + fzf + modules (cross-platform, idempotent; run by `script/install.ps1`). |

The profile runs each topic's `path.ps1` first (PATH setup, like `system/path.ps1`
adding `~/.local/bin`), then dot-sources each topic's other `*.ps1` — e.g.
`powershell/base16.ps1` and `miniconda/conda.ps1`. Installers (`install.ps1`) and
anything under `script/` are skipped.

The starter pack: `posh-git`, `Terminal-Icons`, `PSFzf`, `CompletionPredictor`
(+ built-in `PSReadLine`). Each is imported only if installed, so the profile
works before `install.ps1` has run.

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
backed up), and runs `script\install.ps1` (oh-my-posh + fzf via winget, plus the
module starter pack). Open a new PowerShell 7 window afterward.

Notes:
- Both links are real **symbolic links** (`~/.dotfiles` and `profile.ps1`); if
  Windows can't create one (no Developer Mode and not elevated), bootstrap fails
  with the exception rather than falling back.
- It links the **all-hosts** profile (`profile.ps1` = `$PROFILE.CurrentUserAllHosts`),
  so it loads in every host (console, VS Code, ...) and leaves the host profile
  (`Microsoft.PowerShell_profile.ps1`) untouched — that's where host-specific
  completers and tools live.
- Any existing `profile.ps1` is moved to `profile.ps1.backup`. Put machine-
  specific lines in `~/.localprofile.ps1` (the profile sources it) — conda now
  loads automatically via the `miniconda/` topic, so you usually won't need to.
- Only **PowerShell 7** is wired; Windows PowerShell 5.1 is left alone.
- Git config and base16 aren't set up on Windows by this script (the profile
  still *displays* git/conda state, it just doesn't manage those tools).
- If scripts are blocked by execution policy, run
  `powershell -ExecutionPolicy Bypass -File .\script\bootstrap.ps1` (or
  `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`).

> `niander.omp.json` uses the oh-my-posh v3 config schema, so a current
> oh-my-posh is required; `winget install` provides one.

## base16 theming

base16 themes recolor the terminal by emitting OSC escape sequences at runtime,
not by editing terminal config. `base16.ps1` reuses the exact `base16-*.sh`
definitions from the [`base16-shell/`](../base16-shell) topic — one source of
truth for both shells.

On load the profile auto-applies a theme **when**:

1. the shared enable flag `base16-shell/.base16_enabled` exists (toggle it from
   zsh with `base16 on` / `base16 off`), **and**
2. the terminal honors OSC palette sequences (Windows Terminal, ConEmu/Cmder,
   Windows 11 conhost, or a *nix terminal). GUI terminals that manage their own
   colors (VS Code) and legacy conhost are skipped.

It follows `~/.base16_theme` (the pointer the zsh side maintains), so PowerShell
shows whatever theme you last picked in zsh. Falls back to `eighties`.

Palette slots 16–21 follow the shared `base16 256 on`/`off` toggle: off (the
default) keeps index 16 black so TUIs stay readable; on emits the theme's base09
orange there. Toggle it from zsh; PowerShell reads the same state.

Switch live in a session:

```powershell
Set-Base16Theme gruvbox-dark-hard   # alias: base16 gruvbox-dark-hard  (tab-completes)
Get-Base16Theme                     # list available themes
```

Set `$env:BASE16_SHELL_SET_BACKGROUND = 'false'` before load to keep your
terminal's own background (matches base16-shell's option of the same name).

## Local overrides

Machine-specific PowerShell lives in `~/.localprofile.ps1` (dot-sourced last if
present) — the PowerShell analogue of `~/.localrc`. Keep it out of the repo.
