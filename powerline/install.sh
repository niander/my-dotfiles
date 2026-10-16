#!/bin/sh

set -e

if [ "$(uname -s)" = "Darwin" ]; then
  # Fonts only, same scope as the Linux path below. macOS registers fonts
  # placed in ~/Library/Fonts automatically, so there is no fc-cache step
  # and no fontconfig symbols file. The fonts repo's own install.sh targets
  # Linux directories, so copy the font files directly instead.
  fonts_dir="$HOME/Library/Fonts"
  mkdir -p "$fonts_dir"
  if ! test -d "$DOTFILES/powerline/.powerline-fonts"; then
    git clone https://github.com/powerline/fonts.git "$DOTFILES/powerline/.powerline-fonts" --depth=1
  fi
  find "$DOTFILES/powerline/.powerline-fonts" -type f \( -name '*.ttf' -o -name '*.otf' \) -exec cp -n {} "$fonts_dir/" \;
  if ! test -e "$fonts_dir/PowerlineSymbols.otf"; then
    curl --fail --silent --show-error --location https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf -o "$fonts_dir/PowerlineSymbols.otf"
  fi
  echo "ok       powerline fonts -> $fonts_dir"
  exit 0
fi

# Python powerline engine intentionally NOT installed: the tmux status bar is now native
# (see tmux/tmux.conf.symlink) and vim uses airline. Only the fonts below are still needed.
# Note: the fontconfig install below only affects Linux-native renderers (gvim, kitty,
# gnome-terminal, WSLg, etc.); under Windows Terminal set a Nerd Font in the terminal itself.
# if ! pip show -q powerline-status; then
#   set -x
#   pip install powerline-status
#   set +x
# fi

if ! test -d "$DOTFILES/powerline/.powerline-fonts"; then
  git clone https://github.com/powerline/fonts.git $DOTFILES/powerline/.powerline-fonts --depth=1
  $DOTFILES/powerline/.powerline-fonts/install.sh
fi

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
