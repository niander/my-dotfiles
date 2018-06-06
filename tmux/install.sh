#!/bin/sh

tmuxplugin=$HOME/.tmux/plugins/tpm
if [ -d "$tmuxplugin" ]
then
  cd "$tmuxplugin"
  git pull --rebase --stat origin master
else
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
