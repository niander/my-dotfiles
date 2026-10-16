#!/bin/sh

set -e

case "$(uname -s)" in
    Linux) ;;
    Darwin)
        # Homebrew owns fzf on macOS (darwin/Brewfile); the clone install
        # below is the Linux path.
        if command -v fzf >/dev/null 2>&1; then
            echo "ok       fzf -> $(command -v fzf)"
        else
            echo "note     fzf: not installed; on macOS it comes from Homebrew (script/provision)" >&2
        fi
        exit 0 ;;
    MINGW*|MSYS*|CYGWIN*)
        echo "skip     fzf: on Windows install through script/install.ps1" >&2
        exit 0 ;;
    *)
        echo "skip     fzf: unsupported OS $(uname -s)" >&2
        exit 0 ;;
esac

fzf_dir="$HOME/.fzf"
fzf_bin="$fzf_dir/bin/fzf"

if [ -d "$fzf_dir/.git" ]; then
    git -C "$fzf_dir" pull --rebase --stat origin HEAD
elif [ -e "$fzf_dir" ]; then
    echo "fzf/install.sh: $fzf_dir exists but is not a git checkout" >&2
    exit 1
else
    git clone https://github.com/junegunn/fzf.git "$fzf_dir"
fi

"$fzf_dir/install" --bin

echo "ok       fzf -> $fzf_bin"
