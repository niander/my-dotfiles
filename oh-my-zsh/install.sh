#!/bin/sh

set -e

# install oh my zsh
if ! test -d "$HOME/.oh-my-zsh"
then
  # Refuse to run before bootstrap: ~/.zshrc must already be our symlink, or the
  # upstream installer can create/clobber a real ~/.zshrc.
  if ! test -L "$HOME/.zshrc"
  then
    echo "oh-my-zsh/install.sh: run script/bootstrap first (~/.zshrc is not a symlink)" >&2
    exit 1
  fi
  # Install non-destructively: keep our ~/.zshrc, don't change the login shell,
  # and don't launch zsh. Set zsh as the login shell manually once (see README).
  # Download first so a failed fetch aborts under `set -e`; a piped `wget | sh`
  # would mask wget's exit status (POSIX sh has no pipefail).
  omz_installer="$(mktemp)"
  trap 'rm -f "$omz_installer"' EXIT
  wget -O "$omz_installer" https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
  sh "$omz_installer" --unattended --keep-zshrc
fi

# install zsh-zutosuggestions
ZSH_AUTOSUGGESTIONS=${ZSH_CUSTOM:-"$DOTFILES/oh-my-zsh/custom"}/plugins/zsh-autosuggestions
if ! test -d "$ZSH_AUTOSUGGESTIONS"
then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGESTIONS"
else
    cd "$ZSH_AUTOSUGGESTIONS"
    git pull --rebase --stat origin master
fi

# install conda-zsh-completion
CONDA_ZSH_COMPLETION=${ZSH_CUSTOM:-"$DOTFILES/oh-my-zsh/custom"}/plugins/conda-zsh-completion
if ! test -d "$CONDA_ZSH_COMPLETION"
then
    git clone https://github.com/esc/conda-zsh-completion "$CONDA_ZSH_COMPLETION"
else
    cd "$CONDA_ZSH_COMPLETION"
    git pull --rebase --stat origin master
fi

echo '> You should install python package [pygments]'

