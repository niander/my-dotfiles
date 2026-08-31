#!/usr/bin/env bash

set -euo pipefail

if [[ $OSTYPE != linux* ]]; then
  printf 'skip     utilities: on Windows install through script/install.ps1\n' >&2
  exit 0
fi

if ! command -v apt-get > /dev/null; then
  printf 'skip     utilities: apt-get not found; install them manually\n' >&2
  exit 0
fi

topic=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
repo_root=$(cd -- "$topic/.." && pwd -P)
source "$repo_root/script/lib/sudo.sh"

mapfile -t packages < "$topic/packages.apt"
missing_packages=()
for package in "${packages[@]}"; do
  status=$(dpkg-query -W -f='${db:Status-Abbrev}' "$package" 2>/dev/null || true)
  if [[ $status == ii* ]]; then
    printf 'ok       %s already installed\n' "$package"
  else
    missing_packages+=("$package")
  fi
done

if (( ${#missing_packages[@]} == 0 )); then
  exit 0
fi

if ! dotfiles_sudo 'install command-line utilities' true; then
  printf 'skip     utilities: sudo permission not granted\n' >&2
  exit 0
fi

dotfiles_sudo 'install command-line utilities' apt-get update
dotfiles_sudo 'install command-line utilities' \
  apt-get install -y "${missing_packages[@]}"

printf 'ok       installed %s\n' "${missing_packages[*]}"
