#!/bin/sh

# install oh my zsh
if ! test -d "$HOME/.oh-my-zsh"
then
  wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | sh
  # Make zsh default shell
  which zsh >/dev/null 2>&1 && sudo chsh -s `which zsh`
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

