#!/usr/bin/env bash

set -euo pipefail

readonly tpm_dir="${HOME}/.tmux/plugins/tpm"
readonly tpm_remote="https://github.com/tmux-plugins/tpm"

if ! command -v tmux >/dev/null 2>&1; then
  printf 'tmux/install.sh: tmux is required\n' >&2
  exit 1
fi

if [[ -d "${tpm_dir}/.git" ]]; then
  git -C "$tpm_dir" pull --rebase --stat origin HEAD
elif [[ -e "$tpm_dir" ]]; then
  printf 'tmux/install.sh: %s exists but is not a git checkout\n' "$tpm_dir" >&2
  exit 1
else
  git clone "$tpm_remote" "$tpm_dir"
fi

"${tpm_dir}/bin/install_plugins"
