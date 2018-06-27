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
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_AUTOSUGGESTIONS
else
    cd $ZSH_AUTOSUGGESTIONS
    git pull --rebase --stat origin master
fi

