#!/bin/sh

# install oh my zsh
if ! test -d "$HOME/.oh-my-zsh"
then
  wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | sh
  
  # Make zsh default shell
  which zsh >/dev/null 2>&1 && sudo chsh -s `which zsh`
fi



