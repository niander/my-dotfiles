#!/usr/bin/env bash

set -euo pipefail

if command -v dotnet > /dev/null; then
  printf 'ok       dotnet already installed\n'
  exit 0
fi

[[ $OSTYPE == linux* ]] || exit 0

if [[ -r /etc/os-release ]]; then
  . /etc/os-release
fi

if [[ ${ID:-} == ubuntu ]] && command -v apt > /dev/null; then
  repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
  source "$repo_root/script/lib/sudo.sh"
  dotfiles_sudo 'install .NET SDK 10' apt update
  dotfiles_sudo 'install .NET SDK 10' apt install -y dotnet-sdk-10.0
else
  if ! command -v curl > /dev/null; then
    printf 'dotnet: curl is required to install .NET SDK 10\n' >&2
    exit 1
  fi

  dotnet_installer=$(mktemp)
  trap 'rm -f -- "$dotnet_installer"' EXIT
  curl --fail --silent --show-error --location \
    --output "$dotnet_installer" https://dot.net/v1/dotnet-install.sh
  bash "$dotnet_installer" --channel 10.0 --install-dir "$HOME/.dotnet"
  export DOTNET_ROOT="$HOME/.dotnet"
  export PATH="$DOTNET_ROOT:$PATH"
fi

hash -r
if ! command -v dotnet > /dev/null; then
  printf 'dotnet: installation did not provide the dotnet CLI\n' >&2
  exit 1
fi

printf 'ok       installed .NET SDK 10\n'
