# @niander does dotfiles

My personal dotfiles. Forked from [holman/dotfiles](https://github.com/holman/dotfiles) and reshaped for **Linux, WSL, and Windows (Git Bash / MinGW)**. macOS-specific bits have been dropped.

## Topical layout

Everything is grouped by topic. To add a new area — say, `rust` — make a `rust/` directory and drop files in it:

- `*.zsh` → auto-sourced into your shell
- `path.zsh` → sourced first (set `$PATH` etc.)
- `completion.zsh` → sourced last, after oh-my-zsh has run `compinit`
- `*.symlink` → symlinked (without the extension) into `$HOME` by `script/bootstrap`
- `install.sh` → executed by `script/install` (not auto-sourced)

## What's inside

A few representative topics (folders):

- `zsh/` — shell config, history, options
- `oh-my-zsh/` — oh-my-zsh setup, plugins, custom overrides
- `powershell/` — PowerShell profile: oh-my-posh prompt, module starter pack, base16 theming ([details](powershell/README.md))
- `node/` — Node.js/npm and pnpm setup, plus nvm integration on Linux/WSL
- `rust/` — rustup toolchain installation and Cargo PATH setup
- `git/` — gitconfig, aliases, ignore rules, helpers
- `vim/` — vimrc + plugin setup
- `tmux/` — tmux.conf and tpm
- `docker/` — docker/docker-compose aliases
- `bin/` — small command-line tools on `$PATH`

Notable scripts in `bin/`:

| Command | What it does |
| --- | --- |
| `e` / `ee` | Open in `$EDITOR` (`ee` waits for editors that fork) |
| `git-amend`, `git-credit`, `git-edit-new`, `git-copy-branch-name`, `git-up`, `git-undo`, `git-nuke`, `git-track`, ... | Git workflow helpers |
| `dns-flush` | OS-aware DNS cache flush |
| `yt` | yt-dlp wrapper |

## Install

```sh
git clone https://github.com/niander/my-dotfiles.git
cd my-dotfiles
./script/bootstrap
```

`script/bootstrap` will:

1. Prompt for the Git credential helper, choosing an OS-specific default.
2. Symlink every `*.symlink` file into `$HOME` (with interactive overwrite/backup/skip prompts).
3. Create the `~/.dotfiles` symlink pointing at the repo.
4. Run `script/install`, which executes every topic's `install.sh`.

After that, set zsh as your login shell (one time) and open a new shell so the config loads:

```sh
chsh -s "$(command -v zsh)"
```

### WSL

WSL copies the whole Windows `PATH` into every Linux shell — dozens of cross-filesystem lookups on every command,
nearly all duplicating a Linux binary you already have.

```sh
./wsl/disable-windows-path.sh
```

It sets `appendWindowsPath = false` in `/etc/wsl.conf` (with `sudo`, after showing you the resulting file),
then tells you how to apply and undo it.
`wsl/path.zsh` restores `System32`, `C:\Windows`, and whichever `%PATH%` entries match `wsl/windows-path.keep`,
appended so Linux binaries win. Everything else stays runnable by full path.
Add a path tail to the keep list — `Git/cmd`, say — and the next shell picks it up.

To update later:

```sh
cd ~/.dotfiles
git pull --ff-only
./script/install
```

Per-machine secrets/overrides go in `~/.localrc` (auto-sourced) and
`~/.gitconfig.local` (auto-included by git). Bootstrap configures only the Git
credential helper, not `user.name` or `user.email`.

## Credits

Forked from [holman/dotfiles](https://github.com/holman/dotfiles), which in turn was inspired by [ryanb/dotfiles](https://github.com/ryanb/dotfiles). The topical-dotfiles architecture is theirs.
