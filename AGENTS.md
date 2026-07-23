# AGENTS.md

## Project Overview

Personal dotfiles, forked from [holman/dotfiles](https://github.com/holman/dotfiles) and reshaped for **Linux, WSL, and Windows (Git Bash / MinGW)** — macOS-specific bits were dropped. This is a configuration repo: there is **no build/test/lint suite**; "running" it means installing the config into `$HOME` via the scripts below.

- `README.md` — user-facing install guide.
- `upstream_readme.md` — verbatim snapshot of holman's README, kept only so upstream syncs can diff against it. **Do not follow its install steps** (they clone into `~/.dotfiles`, which breaks this fork's guards).

## Setup Commands

```bash
./script/bootstrap   # one-time: prompts for git identity, symlinks *.symlink into $HOME,
                     # creates the ~/.dotfiles symlink, then runs script/install
./script/install     # re-runnable: runs every topic install.sh (requires ~/.dotfiles symlink)
```

`script/bootstrap` (interactive) does, in order:
1. `setup_gitconfig` — generates `git/gitconfig.local.symlink` from `git/gitconfig.local.symlink.example`, prompting for identity and picking a credential helper by OS (WSL → Windows `git-credential-manager.exe`; native Linux → `cache`; MinGW/MSYS → `manager`). The generated file is gitignored.
2. Symlinks every `*.symlink` into `$HOME` as `.<name>` (interactive skip/overwrite/backup prompts).
3. Creates the **`~/.dotfiles` symlink** to the checkout, then runs `script/install`.

After install, set zsh as the login shell once and open a new shell:
```bash
chsh -s "$(command -v zsh)"
```

## Architecture

Everything is grouped into **topic folders** (`git/`, `vim/`, `tmux/`, `zsh/`, `node/`, `uv/`, …). A file's **extension/name determines its behavior**:

| Pattern | Behavior |
| --- | --- |
| `topic/*.zsh` | Auto-sourced into the shell (see load order below) |
| `topic/path.zsh` | Sourced **first** — sets `$PATH` and similar |
| `topic/completion.zsh` | Sourced **last**, after `compinit` — completion setup |
| `topic/*.symlink` | Symlinked into `$HOME` as `.<name>` (extension stripped) by `script/bootstrap` |
| `topic/install.sh` | Run **once** by `script/install`; named `.sh` (not `.zsh`) precisely so it is *not* auto-sourced every shell |
| `topic/path.ps1` | Dot-sourced into the PowerShell profile **first** — PATH setup, before other `*.ps1` |
| `topic/*.ps1` | Dot-sourced into the PowerShell profile every shell, except `path.ps1` and `install.ps1` |
| `topic/install.ps1` | Run **once** by `script/install.ps1` (cross-platform: WSL2/Windows/macOS) |

### Shell load order (`zsh/zshrc.symlink`)

`zshrc.symlink` → `~/.zshrc` is the entrypoint. It sources `~/.localrc` first (per-machine secrets), then globs `$DOTFILES/*/*.zsh` (**exactly two levels deep**) and sources in three passes:
1. `*/path.zsh` files
2. everything except `path.zsh` and `completion.zsh`
3. `autoload compinit && compinit`, then `*/completion.zsh` files

Non-obvious consequences:
- The glob is only two levels deep, so `oh-my-zsh/custom/*.zsh` files are **not** picked up here. They load via oh-my-zsh's own `ZSH_CUSTOM` mechanism when `oh-my-zsh/completion.zsh` runs `source $ZSH/oh-my-zsh.sh` — i.e. **oh-my-zsh (plugins, theme, custom aliases) initializes in the last/completion pass.**
- Only a file named exactly `path.zsh` sources first. `system/_path.zsh` (underscore) loads in the general pass, not the path pass.
- `zsh/fpath.zsh` adds every top-level topic folder to `$fpath`, which is how autoloaded functions/completions in `functions/` (e.g. `_boom`, `_brew`, `#compdef` scripts) become available.

### bin/ and functions/
- `bin/` is prepended to `$PATH` (`system/_path.zsh`); small executables like `e`/`ee`, the `git-*` helpers, `yt`, `search`.
- `functions/` holds autoloaded zsh functions and `#compdef` completion definitions (reachable via `fpath`).

## Applying changes while developing

- **`*.zsh` change** → open a new shell (files are symlinked live via `~/.zshrc` sourcing `$DOTFILES`).
- **new/changed `*.symlink`** → re-run `./script/bootstrap` (only it creates symlinks).
- **`install.sh` change** → re-run `./script/install`.

`script/install` runs every `install.sh` (`find -maxdepth 2`). These are idempotent — they check-then-clone-or-`git pull` vendored tools (oh-my-zsh, its plugins, tpm, powerline, base16-shell, …), which is why those directories are committed in-tree rather than as submodules (there is no `.gitmodules`).

## Code Style / Conventions

- **Cross-platform:** branch on OS via `uname -s` and `grep -qi microsoft /proc/version` (WSL detection). Keep new shell code working across Linux / WSL / MinGW; don't reintroduce macOS-only assumptions.
- **Per-machine secrets/overrides** stay out of the repo: `~/.localrc` (auto-sourced early by `zshrc`) and `~/.gitconfig.local` (auto-included by git). `.gitignore` excludes all dotfiles (`.*`) and `git/gitconfig.local.symlink`.
- Match the surrounding style of each topic when editing.
- **Comments describe the code, not the change or the machine.** Write comments
  that make sense to someone reading the file cold, with no knowledge of this
  machine or how the code was written. Explain non-obvious *why* in general
  terms. Do **not** put in a comment:
  - references to a specific machine/user or their installed tools (e.g. a hardcoded path, a username);
  - references to a parallel implementation ("mirror of the zsh side", "same as X");
  - meta-narration of the edit or session ("as decided", "see above", "now we…");
  - restatements of what the code plainly does.

## Commit & PR Guidelines

- **Commit messages:** `topic: short description` — **single line** lowercase topic prefix matching the folder (e.g. `tmux: redesign status line`, `omz: require bootstrap`).

## Gotchas

- **`~/.dotfiles` must be the symlink that bootstrap creates.** `script/install` and `oh-my-zsh/install.sh` refuse to run unless `~/.dotfiles` (and `~/.zshrc`) are already symlinks — this guard prevents the upstream oh-my-zsh installer from clobbering a real `~/.zshrc`. **Never clone directly into `~/.dotfiles`**; keep the checkout elsewhere and let bootstrap create the link. `script/install` also verifies `~/.dotfiles` resolves to the checkout it is run from.
