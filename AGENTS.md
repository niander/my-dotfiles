# AGENTS.md

## Project Overview

Personal dotfiles, forked from [holman/dotfiles](https://github.com/holman/dotfiles) and reshaped for **Linux, WSL, and Windows (Git Bash / MinGW)** — macOS-specific bits were dropped. This is a configuration repo: there is **no build/test/lint suite**; "running" it means installing the config into `$HOME` via the scripts below.

- `README.md` — user-facing install guide.
- `upstream_readme.md` — verbatim snapshot of holman's README, kept only so upstream syncs can diff against it. **Do not follow its install steps** (they clone into `~/.dotfiles`, which breaks this fork's guards).

## Setup Commands

```bash
./script/provision   # explicit Ubuntu-on-WSL system provisioning; never runs bootstrap
./script/bootstrap   # one-time: symlinks *.symlink, sources topic bootstrap.sh files,
                     # creates the ~/.dotfiles symlink, then runs script/install
./script/install     # re-runnable: runs every topic install.sh (requires ~/.dotfiles symlink)
```

```powershell
.\script\provision.ps1   # Windows entry point for optional private provisioning
.\script\bootstrap.ps1   # Windows profile, git config and topic installers
```

Provisioning and bootstrap are separate entry points. The WSL provisioner performs the requested package upgrade and system package setup.
The Windows provisioner delegates to the optional private root. Neither invokes bootstrap.

`script/bootstrap` (interactive) does, in order:
1. Symlinks every `*.symlink` into `$HOME` as `.<name>` (interactive skip/overwrite/backup prompts).
2. Creates the **`~/.dotfiles` symlink** to the checkout, prepends an `[include]` of `~/.gitconfig.dotfiles` to `~/.gitconfig` (a regular file), then runs `script/install`.

After install, set zsh as the login shell once and open a new shell:
```bash
chsh -s "$(command -v zsh)"
```

## Architecture

Everything is grouped into **topic folders** (`git/`, `vim/`, `tmux/`, `zsh/`, `node/`, `uv/`, `wsl/`, ...). A file's **extension/name determines its behavior**:

| Pattern | Behavior |
| --- | --- |
| `topic/*.zsh` | Auto-sourced into the shell (see load order below) |
| `topic/path.zsh` | Sourced **first** — sets `$PATH` and similar |
| `topic/completion.zsh` | Sourced **last**, after `compinit` — completion setup |
| `oh-my-zsh/custom/*.zsh` | Sourced by oh-my-zsh itself, after its `lib/` and plugins — the slot for code that must load *after* omz |
| `topic/*.symlink` | Symlinked into `$HOME` as `.<name>` (extension stripped) by `script/bootstrap` |
| `topic/bootstrap.sh` | Sourced by `script/bootstrap` after generic symlinks for topic-owned bootstrap setup |
| `topic/install.sh` | Run **once** by `script/install`; named `.sh` (not `.zsh`) precisely so it is *not* auto-sourced every shell |
| `topic/<other>.sh` | Run by hand only — `script/install` matches the name `install.sh` exactly |
| `topic/path.ps1` | Dot-sourced into the PowerShell profile **first** — PATH setup, before other `*.ps1` |
| `topic/*.ps1` | Dot-sourced into the PowerShell profile every shell, except `path.ps1` and `install.ps1` |
| `topic/install.ps1` | Run **once** by `script/install.ps1` (cross-platform: WSL2/Linux/Windows) |

`script/lib/sudo.sh` exposes `dotfiles_sudo <reason> <command...>` for installers that need root.
Call it only after confirming privileged work is required; it reuses sudo's credential cache and never starts a keepalive.

An optional second topic root lives at `~/.dotfiles.local`, or at `$DOTFILES_LOCAL` when set by `~/.localrc`.
Its zsh and PowerShell files load after the public topics, and its installers run after the public installers.
The public bootstraps run the local root's `script/configure` or `script/configure.ps1` when present, before installers.
The public provisioners run the local root's matching `script/provision` when present.
Every entry point treats an absent local root as a no-op.

### Shell load order (`zsh/zshrc.symlink`)

`zshrc.symlink` -> `~/.zshrc` is the entrypoint. It sources `~/.localrc` first (per-machine secrets), then globs `$DOTFILES/*/*.zsh` (**exactly two levels deep**) and sources in four passes:
1. `*/path.zsh` files
2. everything except `path.zsh`, `completion.zsh` and the oh-my-zsh loader
3. `oh-my-zsh/omz.zsh`, sourced by its exact path rather than by pattern — this is where `compinit` runs
4. `*/completion.zsh` files

When the local topic root exists, its matching files are appended to the same four passes.
Public files therefore load before local files in each pass.

Non-obvious consequences:
- The glob is only two levels deep, so `oh-my-zsh/custom/*.zsh` files are **not** picked up here. They load via oh-my-zsh's own `ZSH_CUSTOM` mechanism when `oh-my-zsh/omz.zsh` runs `source $ZSH/oh-my-zsh.sh` — i.e. **oh-my-zsh (plugins, theme, custom aliases) initializes in pass 3, before any completion file.**
- omz owns the only `compinit`; don't add another to `zshrc.symlink`.
- Inside pass 3 omz loads `lib/*.zsh` -> plugins -> `$ZSH_CUSTOM/*.zsh` -> theme. Anything that must override or survive omz — an option it sets, a `zle` widget hook, an alias a plugin also defines — belongs in `oh-my-zsh/custom/`, not `topic/*.zsh`.
- Only a file named exactly `path.zsh` sources first. `system/_path.zsh` (underscore) loads in the general pass, not the path pass.
- `zsh/fpath.zsh` adds every top-level topic folder to `$fpath`, which is how autoloaded functions/completions in `functions/` (e.g. `_boom`, `_brew`, `#compdef` scripts) become available.

### bin/ and functions/
- `bin/` is prepended to `$PATH` (`system/_path.zsh`); small executables like `e`/`ee`, the `git-*` helpers, `yt`.
- `functions/` holds autoloaded zsh functions and `#compdef` completion definitions (reachable via `fpath`).

## Applying changes while developing

- **`*.zsh` change** -> open a new shell (files are symlinked live via `~/.zshrc` sourcing `$DOTFILES`).
- **prompt / `zle` change** -> verify in a real interactive shell; `zsh -f` loads no plugins, so load-order and widget conflicts don't appear there.
- **new/changed `*.symlink`** -> re-run `./script/bootstrap` (only it creates symlinks).
- **`install.sh` change** -> re-run `./script/install`.
- **`script/provision` change** -> run it explicitly on an Ubuntu WSL host; it upgrades system packages.

`script/install` runs every public `install.sh` (`find -maxdepth 2`), then every local-root `install.sh` when that root exists. `script/install.ps1` uses the same public-then-local order.
These are idempotent — they check-then-clone-or-`git pull` vendored tools (oh-my-zsh, its plugins, tpm, powerline, base16-shell, ...).
Those clones land in dot-directories that `.gitignore` excludes, so they are neither committed nor submodules (there is no `.gitmodules`).

## Code Style / Conventions

- **Cross-platform:** branch on OS via `uname -s`. For WSL, shell config tests `$WSL_DISTRO_NAME`; `script/bootstrap` uses `grep -qi microsoft /proc/version` because it also runs pre-login. Keep new shell code working across Linux / WSL / MinGW; don't reintroduce macOS-only assumptions.
- **Register hooks additively** — use `add-zsh-hook` / `add-zle-hook-widget`. Defining a `precmd`/`preexec` function, or binding a widget with `zle -N`, overwrites any handler oh-my-zsh or a plugin already installed under that name.
- **Per-machine secrets/overrides** stay out of the repo: `~/.localrc` (auto-sourced early by `zshrc`), `~/.gitconfig` (git's global config, which includes the repo baseline) and `~/.gitconfig.local` (auto-included by that baseline). `.gitignore` excludes all dotfiles (`.*`).
- **Privileged installers** source `script/lib/sudo.sh` and call `dotfiles_sudo` only after their unprivileged installed-state check fails.
- Match the surrounding style of each topic when editing.
- **Comments are brief** — usually 1-3 lines. Cut rationale a competent reader can infer; a 6-line explanation almost always wants to be 2. Describe the code, not the change or the machine. Write for someone reading the file cold, with no knowledge of this machine or how the code was written. Explain non-obvious *why* tersely. Do **not** put in a comment:
  - references to a specific machine/user, their installed tools, or a product/app name (e.g. a hardcoded path, a username, a specific editor/app);
  - references to a parallel implementation ("mirror of the zsh side", "same as X");
  - meta-narration of the edit or session ("as decided", "see above", "now we...");
  - restatements of what the code plainly does; prefer a clear name over a comment (e.g. `$esc` not `$e` + a comment).
- **No cosmetic alignment** — don't pad with extra spaces to line up `=`, braces, or trailing comments.

## Commit & PR Guidelines

- **Commit messages:** `topic: short description` — **single line** lowercase topic prefix matching the folder (e.g. `tmux: redesign status line`, `omz: require bootstrap`).

## Gotchas

- On every platform `~/.gitconfig` is a regular file whose first two lines include `~/.gitconfig.dotfiles` (the linked baseline, `git/gitconfig.dotfiles.symlink`); `git config --global` writes land on the machine and override it. `script/bootstrap` and `script/bootstrap.ps1` share one contract: the include must be the first entry, so both decide by reading the opening two lines directly (`gitconfig_include_first` / `Test-GitIncludeFirst`) — `git config --file` only guards against an unparsable file and answers "is it present elsewhere". Neither rewrites an existing entry.
- In Git Bash, `ln -s` deep-copies by default. `script/bootstrap` exports `MSYS=winsymlinks:nativestrict` to create native links, which also require Developer Mode.
- Git for Windows rewrites path-like arguments. Passing `~/.dotfiles/...` to `git config` stores a native path that no longer matches the expected value.
- Let bootstrap create `~/.dotfiles` as a symlink. `script/install` and `oh-my-zsh/install.sh` require both it and `~/.zshrc` to be symlinks, preventing the upstream installer from replacing a real `~/.zshrc`. Do not clone directly into `~/.dotfiles`; `script/install` also checks that the link resolves to its checkout.
- WSL does not inherit the Windows `PATH` — `wsl/disable-windows-path.sh` turns off `appendWindowsPath`, and `wsl/path.zsh` reads `%PATH%` back from `cmd.exe` on every shell (~50 ms) to re-add the keepers. What it restores is zsh-only: bash scripts, systemd user services and `wsl -e <cmd>` see no Windows `PATH` at all. Without a Win32 directory on `PATH` interop cannot resolve *any* `.exe` (`bin/git-copy-branch-name` needs `clip.exe`), which is why System32 is added unconditionally. `/etc/wsl.conf` must stay LF with no BOM or WSL ignores it silently.
- `extendedglob` is **off** in this config, interactively included. `[[:space:]]#`, `(#i)`, `/##`, `^` and `~` are ordinary characters unless a file turns it on — use `setopt localoptions extendedglob` inside an anonymous function, as `wsl/path.zsh` does, rather than setting it globally.
