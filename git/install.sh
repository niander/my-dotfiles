#!/usr/bin/env bash

set -euo pipefail

if [[ $OSTYPE == darwin* ]]; then
  # On macOS both tools come from darwin/Brewfile (script/provision):
  # git-delta is the pager gitconfig sets, and the Git Credential Manager
  # cask is the credential helper. Nothing to install here; just verify,
  # so a missing provision run is visible instead of a silent pager or
  # credential failure later.
  if command -v delta > /dev/null; then
    printf 'ok       delta already installed\n'
  else
    printf 'note     delta not found; run script/provision (git-delta in darwin/Brewfile)\n' >&2
  fi
  if command -v git-credential-manager > /dev/null; then
    printf 'ok       Git Credential Manager already installed\n'
  else
    printf 'note     Git Credential Manager not found; run script/provision (cask in darwin/Brewfile)\n' >&2
  fi
  exit 0
fi

[[ $OSTYPE == linux* ]] || exit 0

export PATH="$HOME/.dotnet/tools:$PATH"

if command -v git-credential-manager > /dev/null; then
  printf 'ok       Git Credential Manager already installed\n'
  exit 0
fi

if ! command -v dotnet > /dev/null; then
  repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
  "$repo_root/dotnet/install.sh"

  if [[ -x $HOME/.dotnet/dotnet ]]; then
    export DOTNET_ROOT="$HOME/.dotnet"
    export PATH="$DOTNET_ROOT:$PATH"
  fi
fi

if ! command -v dotnet > /dev/null; then
  printf 'git: dotnet is required to install Git Credential Manager\n' >&2
  exit 1
fi

if dotnet tool list --global | grep -q '^git-credential-manager[[:space:]]'; then
  dotnet tool update --global git-credential-manager
else
  dotnet tool install --global git-credential-manager
fi

hash -r
if ! command -v git-credential-manager > /dev/null; then
  printf 'git: Git Credential Manager is not available after installation\n' >&2
  exit 1
fi

printf 'ok       installed Git Credential Manager\n'
printf 'note     run git-credential-manager configure manually to enable it\n'
if ! git config --global --get credential.credentialStore > /dev/null; then
  printf 'note     choose a native Linux GCM credential store manually\n'
fi
