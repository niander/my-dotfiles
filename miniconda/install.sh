#!/bin/bash

dirname="$(dirname $0)"

echo ''

if test -d "$HOME/miniconda3"
then
  echo 'Current installation of miniconda 3 was found at ~/miniconda'
  echo ''
else
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $dirname/miniconda-latest-linux-64.sh
  chmod +x $dirname/miniconda-latest-linux-64.sh
  bash $dirname/miniconda-latest-linux-64.sh -b
  rm -f $dirname/miniconda-latest-linux-64.sh
fi