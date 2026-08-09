#!/bin/sh
# Stop WSL from appending the whole Windows PATH to every process in the distro.
# Run by hand: needs sudo and a distro restart.

if [ -z "$WSL_DISTRO_NAME" ]; then
    echo "skip     windows path: not running under WSL" >&2
    exit 0
fi

conf=/etc/wsl.conf
cr=$(printf '\r')

src=/dev/null
if [ -f "$conf" ]; then
    src="$conf"
    if grep -q "$cr" "$conf" || [ "$(head -c 3 "$conf")" = "$(printf '\357\273\277')" ]; then
        echo "note     wsl.conf has DOS line endings or a BOM, so WSL has been ignoring it" >&2
    fi
fi

tmp=$(mktemp) || exit 1
trap 'rm -f "$tmp"' EXIT INT TERM

# Set appendWindowsPath under [interop], creating the section if absent. A leading BOM
# and every CR go: WSL silently ignores a wsl.conf carrying either.
awk '
    NR == 1 { sub(/^\357\273\277/, "") }
    { sub(/\r$/, "") }
    /^[ \t]*\[/ {
        section = tolower($0)
        sub(/^[ \t]*\[[ \t]*/, "", section)
        sub(/[ \t]*\][ \t]*$/, "", section)
        print
        if (section == "interop" && !done) { print "appendWindowsPath = false"; done = 1 }
        next
    }
    section == "interop" && /^[ \t]*appendWindowsPath[ \t]*=/ { next }
    { print }
    END {
        if (!done) {
            if (NR > 0) print ""
            print "[interop]"
            print "appendWindowsPath = false"
        }
    }
' "$src" > "$tmp"

if cmp -s "$tmp" "$src"; then
    echo "ok       wsl.conf: appendWindowsPath already disabled"
    exit 0
fi

echo "         $conf would become:"
sed 's/^./           &/' "$tmp"
printf '         write it with sudo? [y/N] '
read -r reply
case "$reply" in
    [Yy]*) ;;
    *)
        echo "skip     wsl.conf left unchanged" >&2
        exit 0 ;;
esac

if ! sudo install -m 644 -o root -g root "$tmp" "$conf"; then
    echo "warn     wsl.conf: write failed" >&2
    exit 1
fi
echo "ok       wsl.conf: appendWindowsPath = false"

cat <<EOF

Restart the distro for this to take effect. From Windows:

    wsl -t $WSL_DISTRO_NAME

Wait a few seconds -- WSL needs the distro fully stopped -- then open a new shell.
Use 'wsl --shutdown' only if you want every distro stopped.

To undo: delete the [interop] block from $conf and restart again.
EOF
