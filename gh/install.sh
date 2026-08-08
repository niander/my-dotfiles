#!/bin/sh
# Install the GitHub CLI (gh) into the user's local bin directory and refresh
# its shell completions. Uses a prebuilt release so no root/package manager is
# required.

topic=$(CDPATH= cd "$(dirname "$0")" && pwd)

case "$(uname -s)" in
    Linux) ;;
    MINGW*|MSYS*|CYGWIN*)
        echo "skip     gh: on Windows install through script/install.ps1" >&2
        exit 0 ;;
    *)
        echo "skip     gh: unsupported OS $(uname -s)" >&2
        exit 0 ;;
esac

if ! command -v gh >/dev/null 2>&1; then
    case "$(uname -m)" in
        x86_64) arch=amd64 ;;
        aarch64|arm64) arch=arm64 ;;
        *)
            echo "skip     gh: no prebuilt binary for $(uname -m); install gh yourself" >&2
            exit 0 ;;
    esac
    if ! command -v curl >/dev/null 2>&1; then
        echo "skip     gh: curl not found" >&2
        exit 0
    fi

    # Release asset names embed the version, so read it off the redirect
    # target of /releases/latest.
    latest=$(curl -fsSLI -o /dev/null -w '%{url_effective}' https://github.com/cli/cli/releases/latest)
    case "$latest" in
        */tag/v*) version=${latest##*/tag/v} ;;
        *)
            echo "warn     gh: could not resolve the latest release" >&2
            version= ;;
    esac

    if [ -n "$version" ]; then
        echo "install  gh $version (release binary) ..."
        tmp=$(mktemp -d)
        name="gh_${version}_linux_${arch}"
        url="https://github.com/cli/cli/releases/download/v${version}/${name}.tar.gz"
        if curl -fsSL "$url" -o "$tmp/gh.tar.gz" && tar -xzf "$tmp/gh.tar.gz" -C "$tmp"; then
            mkdir -p "$HOME/.local/bin"
            mv "$tmp/$name/bin/gh" "$HOME/.local/bin/gh"
            chmod +x "$HOME/.local/bin/gh"
            echo "ok       gh -> $HOME/.local/bin/gh"
        else
            echo "warn     gh: binary download failed" >&2
        fi
        rm -rf "$tmp"
    fi
fi

gh_bin=$(command -v gh 2>/dev/null)
[ -n "$gh_bin" ] || gh_bin="$HOME/.local/bin/gh"
if [ ! -x "$gh_bin" ]; then
    exit 0
fi

# Zsh autoloads _gh through fpath; the PowerShell profile dot-sources _gh.ps1.
# Generate into a temp file so a failure leaves the previous completion intact
# rather than an empty one, which loses the #compdef tag and breaks silently.
comp_tmp=$(mktemp -d)
for shell in zsh powershell; do
    case "$shell" in
        zsh) dest="$topic/_gh"; label="zsh" ;;
        powershell) dest="$topic/_gh.ps1"; label="pwsh" ;;
    esac
    if "$gh_bin" completion -s "$shell" > "$comp_tmp/out" 2>/dev/null && [ -s "$comp_tmp/out" ]; then
        mv "$comp_tmp/out" "$dest"
        echo "ok       gh $label completion"
    else
        echo "warn     gh $label completion failed" >&2
    fi
done
rm -rf "$comp_tmp"

# The github.com credential helper only answers once an account is stored.
if ! "$gh_bin" auth status >/dev/null 2>&1; then
    echo "todo     gh: run 'gh auth login' to enable the github.com credential helper" >&2
fi
