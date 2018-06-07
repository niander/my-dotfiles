#!/bin/sh

if ! `whereis tmux >/dev/null 2>&1`
then
  echo 'you should install tmux'
  exit 1
fi

tmuxplugin=$HOME/.tmux/plugins/tpm
if [ -d "$tmuxplugin" ]
then
  cd "$tmuxplugin"
  git pull --rebase --stat origin master
else
  git clone https://github.com/tmux-plugins/tpm $tmuxplugin
fi
