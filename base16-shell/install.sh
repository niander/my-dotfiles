#!/bin/sh

set -e

# tinted-shell (the maintained successor to chriskempson/base16-shell). After
# updating, gate every theme's ANSI-256 slot 16-21 writes behind
# $BASE16_SHELL_SET_256COLORSPACE. base16 remaps those slots to base09 orange etc.,
# clobbering the standard 256-color cube (index 16 = black) and making TUIs that
# treat 16 as black unreadable (e.g. Claude Code). Off by default; toggle it back
# on (for base16-vim in 256-color mode) via `base16 256 on` -- see config.zsh.

BASE16_SHELL="$DOTFILES/base16-shell/.base16-shell"
BASE16_REMOTE="https://github.com/tinted-theming/tinted-shell.git"
BASE16_BRANCH="main"

if [ ! -d "$BASE16_SHELL/.git" ]; then
  git clone "$BASE16_REMOTE" "$BASE16_SHELL"
fi

cd "$BASE16_SHELL"

# Retarget old clones at tinted-shell and hard-reset so the patch below re-applies
# cleanly on every run and never conflicts with an update.
git remote set-url origin "$BASE16_REMOTE"
git fetch --quiet origin "$BASE16_BRANCH"
git checkout --quiet -f -B "$BASE16_BRANCH" "origin/$BASE16_BRANCH"

for script in scripts/*.sh; do
  sed -i -E \
    's/^([[:space:]]*)(put_template (1[6-9]|2[01]) .*)$/\1[ -n "${BASE16_SHELL_SET_256COLORSPACE}" ] \&\& \2/' \
    "$script"
done
