# @niander does dotfiles

My personal dotfiles. Forked from [holman/dotfiles](https://github.com/holman/dotfiles) and reshaped for **Linux, WSL, and Windows (Git Bash / MinGW)**. macOS-specific bits have been dropped.

## Topical layout

Everything is grouped by topic. To add a new area — say, `rust` — make a `rust/` directory and drop files in it:

- `*.zsh` → auto-sourced into your shell
- `path.zsh` → sourced first (set `$PATH` etc.)
- `completion.zsh` → sourced last, after oh-my-zsh has run `compinit`
- `*.symlink` → symlinked (without the extension) into `$HOME` by `script/bootstrap`
- `install.sh` → executed by `script/install` (not auto-sourced)

An optional second topic root can live at `~/.dotfiles.local`, or at the path set in `DOTFILES_LOCAL` by `~/.localrc`.
Its zsh and PowerShell files load after the public topics, and its install scripts run after the public installers.
If the root is absent, setup and shell startup are unchanged.

## What's inside

A few representative topics (folders):

- `zsh/` — shell config, history, options
- `oh-my-zsh/` — oh-my-zsh setup, plugins, custom overrides
- `powershell/` — PowerShell profile: oh-my-posh prompt, module starter pack, base16 theming ([details](powershell/README.md))
- `dotnet/` — .NET SDK 10 on Ubuntu/WSL and .NET global-tool PATH setup
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

1. Symlink every `*.symlink` file into `$HOME` (with interactive overwrite/backup/skip prompts).
2. Create the `~/.dotfiles` symlink pointing at the repo.
3. Prepend an include of `~/.gitconfig.dotfiles` (the symlinked baseline) to `~/.gitconfig`.
   It stops rather than guessing if `~/.gitconfig` is a symlink to somewhere outside this checkout, or already carries the include below the top — move those settings aside first.
4. Run `script/install`, which executes every topic's `install.sh`.

After that, set zsh as your login shell (one time) and open a new shell so the config loads:

```sh
chsh -s "$(command -v zsh)"
```

### WSL

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

Per-machine secrets and overrides go in `~/.localrc` (auto-sourced) and `~/.gitconfig.local` (auto-included by Git).

For larger untracked extensions, create a directory or symlink at `~/.dotfiles.local` using the same topical layout.
Set `DOTFILES_LOCAL` in `~/.localrc` first if it lives elsewhere.

`~/.gitconfig` is the one file bootstrap does not symlink.
It stays a regular file with the repo baseline included on top:

```ini
[include]
	path = ~/.gitconfig.dotfiles
```

so `git config --global` writes stay on the machine and override the baseline.

## Credits

Forked from [holman/dotfiles](https://github.com/holman/dotfiles), which in turn was inspired by [ryanb/dotfiles](https://github.com/ryanb/dotfiles). The topical-dotfiles architecture is theirs.
