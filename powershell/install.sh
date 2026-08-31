#!/usr/bin/env bash

set -euo pipefail

if command -v pwsh > /dev/null; then
  printf 'ok       PowerShell already installed\n'
  exit 0
fi

if ! command -v apt-get > /dev/null; then
  printf 'skip     PowerShell: apt-get not found; install it manually\n' >&2
  exit 0
fi

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
source "$repo_root/script/lib/sudo.sh"

if ! dotfiles_sudo 'install PowerShell' true; then
  printf 'skip     PowerShell: sudo permission not granted\n' >&2
  exit 0
fi

dotfiles_sudo 'install PowerShell' apt-get update
dotfiles_sudo 'install PowerShell' apt-get install -y powershell

hash -r
if ! command -v pwsh > /dev/null; then
  printf 'PowerShell: installation did not provide the pwsh command\n' >&2
  exit 1
fi

printf 'ok       PowerShell installed\n'
