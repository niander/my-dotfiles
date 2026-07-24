#!/bin/sh

set -e

# Update vendored tinted-shell and optionally set ANSI-256 slots 16-21.
# Keep index 16 black by default; enable remapping with `base16 256 on`.

BASE16_SHELL="$DOTFILES/base16-shell/.base16-shell"
BASE16_REMOTE="https://github.com/tinted-theming/tinted-shell.git"
BASE16_BRANCH="main"

if [ ! -d "$BASE16_SHELL/.git" ]; then
  git clone "$BASE16_REMOTE" "$BASE16_SHELL"
fi

cd "$BASE16_SHELL"

# Retarget old clones and hard-reset (not pull) so the patch below always reapplies cleanly.
git remote set-url origin "$BASE16_REMOTE"
git fetch --quiet origin "$BASE16_BRANCH"
git checkout --quiet -f -B "$BASE16_BRANCH" "origin/$BASE16_BRANCH"

sed -i -E \
  's/^([[:space:]]*)(put_template (1[6-9]|2[01]) .*)$/\1[ -n "${BASE16_SHELL_SET_256COLORSPACE}" ] \&\& \2/' \
  scripts/*.sh
