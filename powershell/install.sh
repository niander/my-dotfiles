#!/bin/sh
#
# Install PowerShell tooling: oh-my-posh (prompt) and the module starter pack.
# Optional/secondary tooling -- network or missing prerequisites must not abort
# the rest of script/install, so the two fetches below are non-fatal.

set -e

# --- oh-my-posh (Linux/macOS) ----------------------------------------------
# On Windows install it with `winget install JanDeDobbeleer.OhMyPosh` instead
# (see README.md); this branch handles the *nix side only.
# Check the install target too, not just PATH: script/install may run without
# ~/.local/bin on PATH, and skipping that check would re-download every run.
if ! command -v oh-my-posh >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/oh-my-posh" ]; then
  if command -v curl >/dev/null 2>&1; then
    mkdir -p "$HOME/.local/bin"
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin" || \
      echo "powershell/install.sh: oh-my-posh install skipped (network?)" >&2
  fi
fi

# --- PowerShell modules -----------------------------------------------------
if command -v pwsh >/dev/null 2>&1; then
  pwsh -NoProfile -Command '
    foreach ($m in @("posh-git","Terminal-Icons","PSFzf","CompletionPredictor")) {
      if (-not (Get-Module -ListAvailable -Name $m)) {
        Install-Module $m -Scope CurrentUser -Force -AllowClobber -ErrorAction SilentlyContinue
      }
    }
  ' || echo "powershell/install.sh: module install skipped" >&2
fi
