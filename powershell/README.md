# powershell

PowerShell profile for this dotfiles repo: an [oh-my-posh](https://ohmyposh.dev)
prompt that mirrors the zsh theme, a small module starter pack, PSReadLine
inline predictions, and **base16 theming that follows the same theme the zsh
side selects**.

## What's here

| File | Purpose |
| --- | --- |
| `config/powershell/Microsoft.PowerShell_profile.ps1.symlink` | The profile. Symlinked to `~/.config/powershell/Microsoft.PowerShell_profile.ps1` on Linux/WSL by `script/bootstrap`. |
| `base16.ps1` | Runtime base16 loader — dot-sourced by the profile. Re-emits the shared `base16-shell/` themes as OSC sequences. |
| `niander.omp.json` | oh-my-posh theme (uses ANSI color names so it recolors with base16). |
| `install.sh` | Installs oh-my-posh + modules (idempotent; run by `script/install`). |

The starter pack: `posh-git`, `Terminal-Icons`, `PSFzf`, `CompletionPredictor`
(+ built-in `PSReadLine`). Each is imported only if installed, so the profile
works before `install.sh` has run.

## Linux / WSL (PowerShell 7)

Handled automatically. `script/bootstrap` symlinks the profile into
`~/.config/powershell/`, and `script/install` runs `install.sh`. Open a new
`pwsh` session.

## Windows

PowerShell on Windows reads its profile from a different location, so the
symlink is **not** picked up. Add a one-line dot-source to your `$PROFILE`:

```powershell
# In $PROFILE  (run `notepad $PROFILE`; for both 5.1 and 7, do this in each)
. "$HOME\.dotfiles\powershell\config\powershell\Microsoft.PowerShell_profile.ps1"
```

Install the tooling once (native package managers are cleaner than the *nix
script on Windows):

```powershell
winget install JanDeDobbeleer.OhMyPosh          # oh-my-posh
Install-Module posh-git, Terminal-Icons, PSFzf, CompletionPredictor -Scope CurrentUser
```

`fzf` is needed for PSFzf's `Ctrl+T` / `Ctrl+R` (`winget install junegunn.fzf`).

> `niander.omp.json` uses the oh-my-posh v3 config schema, so a current
> oh-my-posh is required. `winget install` and the `install.sh` curl fetch both
> provide one; a stale distro-packaged build may be too old.

> `$HOME\.dotfiles` must be the symlink `script/bootstrap` creates. If you only
> use this repo on Windows, run `script/bootstrap` from Git Bash first so
> `~/.dotfiles` exists.

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
