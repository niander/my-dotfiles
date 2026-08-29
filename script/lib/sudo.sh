#!/usr/bin/env bash

dotfiles_sudo() {
  local reason=$1
  shift

  if (( EUID == 0 )); then
    "$@"
    return
  fi

  if ! command -v sudo > /dev/null; then
    printf 'sudo is required to %s, but it is not installed\n' "$reason" >&2
    return 1
  fi

  if [[ ${DOTFILES_SUDO_VALIDATED:-} != true ]]; then
    if ! sudo -n true 2>/dev/null; then
      if [[ ! -t 2 ]]; then
        printf 'sudo is required to %s; rerun script/install from an interactive terminal\n' "$reason" >&2
        return 1
      fi

      printf 'sudo     %s\n' "$reason"
      sudo -v || return
    fi
    DOTFILES_SUDO_VALIDATED=true
  fi

  sudo "$@"
}
