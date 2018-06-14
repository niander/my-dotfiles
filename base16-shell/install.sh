#!/bin/sh

BASE16_SHELL=$HOME/.config/base16-shell/
if ! test -d $BASE16_SHELL
then
  git clone https://github.com/chriskempson/base16-shell.git $BASE16_SHELL
else
  cd $BASE16_SHELL
  git pull --rebase --stat origin master
fi
