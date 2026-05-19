# @niander does dotfiles

My personal dotfiles. Forked from [holman/dotfiles](https://github.com/holman/dotfiles) and reshaped for **Linux, WSL, and Windows (Git Bash / MinGW)**. macOS-specific bits have been dropped.

## Topical layout

Everything is grouped by topic. To add a new area — say, `rust` — make a `rust/` directory and drop files in it:

- `*.zsh` → auto-sourced into your shell
- `path.zsh` → sourced first (set `$PATH` etc.)
- `completion.zsh` → sourced last (zsh completion setup)
- `*.symlink` → symlinked (without the extension) into `$HOME` by `script/bootstrap`
- `install.sh` → executed by `script/install` (not auto-sourced)

## What's inside

Topic dirs: `atuin/`, `base16-shell/`, `bin/`, `docker/`, `editors/`, `functions/`, `git/`, `miniconda/`, `node/`, `oh-my-zsh/`, `powerline/`, `R/`, `system/`, `tmux/`, `vim/`, `zsh/`.

Notable scripts in `bin/`:

| Command | What it does |
| --- | --- |
| `dot` | Re-bootstrap: pulls the repo, upgrades system packages (apt/dnf/pacman/winget), runs all `install.sh` scripts |
| `e` / `ee` | Open in `$EDITOR` (`ee` waits for editors that fork) |
| `a` | Launch your default AI client (default: `claude`) |
| `git-amend`, `git-credit`, `git-edit-new`, `git-copy-branch-name`, `git-up`, `git-undo`, `git-nuke`, `git-track`, … | Git workflow helpers |
| `dns-flush` | OS-aware DNS cache flush |
| `yt` | yt-dlp wrapper |
| `search` | `ack`/`ack-grep` shortcut |
| `todo` | Quick todo |

## Install

```sh
git clone https://github.com/niander/my-dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```

`script/bootstrap` will:

1. Prompt for your git identity and pick a sensible credential helper for your OS (WSL → Windows credential manager; native Linux → `cache`; MinGW/MSYS → `manager`).
2. Symlink every `*.symlink` file into `$HOME` (with interactive overwrite/backup/skip prompts).
3. Create the `~/.dotfiles` symlink if needed.

Then run `script/install` (or just `dot`) to install per-topic dependencies.

Per-machine secrets/overrides go in `~/.localrc` (auto-sourced) and `~/.gitconfig.local` (auto-included by git).

## Keeping in sync with upstream

`holman/dotfiles` keeps evolving and is occasionally worth raiding. To pull in new ideas:

```sh
git remote add upstream https://github.com/holman/dotfiles.git
git fetch upstream
git log --oneline master..upstream/master      # what's new upstream
git diff --stat master..upstream/master        # which files changed
```

Cherry-pick concepts, not commits — most upstream changes are macOS-only.

## Credits

Originally forked from [holman/dotfiles](https://github.com/holman/dotfiles), which in turn was inspired by [ryanb/dotfiles](https://github.com/ryanb/dotfiles). All of the original topical-dotfiles architecture is theirs; this fork just adapts it for non-macOS environments.
