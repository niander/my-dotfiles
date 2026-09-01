#!/usr/bin/env bash

set -euo pipefail

if command -v uv > /dev/null; then
  printf 'ok       uv already installed\n'
  exit 0
fi

if [[ $OSTYPE != linux* ]]; then
  printf 'skip     uv: on Windows install through script/install.ps1\n' >&2
  exit 0
fi

uv_installer=$(mktemp)
trap 'rm -f -- "$uv_installer"' EXIT

curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location \
  --output "$uv_installer" https://astral.sh/uv/install.sh
UV_INSTALL_DIR="$HOME/.local/bin" UV_NO_MODIFY_PATH=1 sh "$uv_installer"

printf 'ok       installed uv\n'
