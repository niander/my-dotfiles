#!/usr/bin/env bash

if [ "$(uname -s)" = "Darwin" ]; then
  local ghostty_src="$DOTFILES_ROOT/ghostty/config.ghostty"
  local ghostty_dst="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config.ghostty"

  mkdir -p "$(dirname "$ghostty_dst")"
  link_file "$ghostty_src" "$ghostty_dst"
fi
