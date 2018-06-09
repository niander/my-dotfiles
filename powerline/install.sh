#!/bin/sh

if ! pip show -q powerline-status; then
  set -x
  pip install powerline-status
  set +x
fi

#git clone https://github.com/powerline/fonts.git fontsinstall --depth=1
# install
#cd fontsinstall
#./install.sh
# clean-up a bit
#cd ..
#rm -rf fontsinstall

if ! test -e "$HOME/.local/share/fonts/PowerlineSymbols.otf"; then
  wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
  mkdir -p -v $HOME/.local/share/fonts/
  mv -v PowerlineSymbols.otf $HOME/.local/share/fonts/
  fc-cache -vf ~/.local/share/fonts/
fi

if ! test -e "$HOME/.config/fontconfig/conf.d/10-powerline-symbols.conf"; then
  wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
  mkdir -p -v $HOME/.config/fontconfig/conf.d/
  mv -v 10-powerline-symbols.conf ~/.config/fontconfig/conf.d/
fi
