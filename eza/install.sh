#!/bin/sh
# Install eza (a modern ls replacement) to the user's local bin directory and
# download the latest upstream shell completions. This script provides a binary
# only for x86_64 Linux; install eza manually on other architectures.

topic=$(CDPATH= cd "$(dirname "$0")" && pwd)
raw="https://raw.githubusercontent.com/eza-community/eza/main/completions"

# Install the release binary only when eza is not already on PATH. Because eza
# is compiled, this script downloads a prebuilt release rather than a checkout.
if ! command -v eza >/dev/null 2>&1; then
    if [ "$(uname -m)" != "x86_64" ]; then
        echo "skip     eza: no prebuilt binary for $(uname -m); install eza yourself" >&2
        exit 0
    fi
    if ! command -v curl >/dev/null 2>&1; then
        echo "skip     eza: curl not found" >&2
        exit 0
    fi
    echo "install  eza (release binary) ..."
    tmp=$(mktemp -d)
    url="https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz"
    if curl -fsSL "$url" -o "$tmp/eza.tar.gz" && tar -xzf "$tmp/eza.tar.gz" -C "$tmp"; then
        mkdir -p "$HOME/.local/bin"
        mv "$tmp/eza" "$HOME/.local/bin/eza"
        chmod +x "$HOME/.local/bin/eza"
        echo "ok       eza -> $HOME/.local/bin/eza"
    else
        echo "warn     eza: binary download failed" >&2
    fi
    rm -rf "$tmp"
fi

# Download completions on every run so they remain current. Zsh autoloads _eza
# through fpath, and the PowerShell profile dot-sources _eza.ps1. Failures here
# are non-fatal because eza works without shell completions.
if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$raw/zsh/_eza" -o "$topic/_eza" && echo "ok       eza zsh completion" || echo "warn     eza zsh completion fetch failed" >&2
    curl -fsSL "$raw/pwsh/_eza.ps1" -o "$topic/_eza.ps1" && echo "ok       eza pwsh completion" || echo "warn     eza pwsh completion fetch failed" >&2
fi
