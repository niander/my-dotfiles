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

Topic dirs: `base16-shell/`, `bin/`, `docker/`, `editors/`, `functions/`, `git/`, `miniconda/`, `node/`, `oh-my-zsh/`, `powerline/`, `R/`, `system/`, `tmux/`, `vim/`, `zsh/`.

Notable scripts in `bin/`:

| Command | What it does |
| --- | --- |
| `e` / `ee` | Open in `$EDITOR` (`ee` waits for editors that fork) |
| `git-amend`, `git-credit`, `git-edit-new`, `git-copy-branch-name`, `git-up`, `git-undo`, `git-nuke`, `git-track`, … | Git workflow helpers |
| `dns-flush` | OS-aware DNS cache flush |
| `yt` | yt-dlp wrapper |
| `search` | `ack`/`ack-grep` shortcut |
| `todo` | Quick todo |

## Install

```sh
git clone https://github.com/niander/my-dotfiles.git ~/dotfiles
cd ~/dotfiles
script/bootstrap
```

> Pick any clone path you like (e.g. `~/code/dotfiles`, `~/projects/dotfiles`) — just **don't clone into `~/.dotfiles`**. `script/bootstrap` creates `~/.dotfiles` as a symlink to wherever the repo lives, and that symlink is later used as a "bootstrap-was-run" marker by `script/install`.

`script/bootstrap` will:

1. Prompt for your git identity and pick a sensible credential helper for your OS (WSL → Windows credential manager; native Linux → `cache`; MinGW/MSYS → `manager`).
2. Symlink every `*.symlink` file into `$HOME` (with interactive overwrite/backup/skip prompts).
3. Create the `~/.dotfiles` symlink pointing at the repo.
4. Run `script/install`, which executes every topic's `install.sh`.

After that, open a new shell so the zsh config loads.

To refresh later (e.g. after pulling new topics):

```sh
git -C ~/dotfiles pull --ff-only && ~/dotfiles/script/install
```

Per-machine secrets/overrides go in `~/.localrc` (auto-sourced) and `~/.gitconfig.local` (auto-included by git).

## Credits

Forked from [holman/dotfiles](https://github.com/holman/dotfiles), which in turn was inspired by [ryanb/dotfiles](https://github.com/ryanb/dotfiles). The topical-dotfiles architecture is theirs.
