#!/usr/bin/env bash

set -euo pipefail

if command -v rustup > /dev/null; then
  printf 'ok       rustup already installed\n'
  exit 0
fi

if [[ $OSTYPE != darwin* ]]; then
  printf 'skip     rust: the rustup installer here covers macOS; Windows uses script/install.ps1\n' >&2
  exit 0
fi

# Download to a file in a separate step (mirrors uv/install.sh): a failed or
# partial fetch then aborts under set -e before any installer code runs.
rustup_installer=$(mktemp)
trap 'rm -f -- "$rustup_installer"' EXIT

curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location \
  --output "$rustup_installer" https://sh.rustup.rs
# No PATH edits: rust/path.zsh already puts ~/.cargo/bin on PATH.
sh "$rustup_installer" -y --no-modify-path

printf 'ok       installed rustup\n'
