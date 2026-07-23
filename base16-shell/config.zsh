BASE16_SHELL=$DOTFILES/base16-shell/.base16-shell
BASE16_ENABLED_FILE=$DOTFILES/base16-shell/.base16_enabled
# Marker file: when present, restore base16's ANSI-256 slots 16-21 (see install.sh).
BASE16_256_FILE=$DOTFILES/base16-shell/.base16_256colorspace

function toggle_base16_shell() {
    case "$1" in
        on)
            touch "$BASE16_ENABLED_FILE" || return
            ;;
        off)
            rm -f "$BASE16_ENABLED_FILE"
            ;;
        status)
            [[ -f "$BASE16_ENABLED_FILE" ]] && echo "base16 is on" || echo "base16 is off"
            ;;
        256)
            # Toggle the ANSI-256 slot 16-21 remap (base09 orange, etc). Off keeps
            # index 16 = black so TUIs like Claude Code stay readable; on restores
            # the full palette for base16-vim in 256-color mode. Persisted via the
            # marker file, so it survives new shells.
            case "$2" in
                on)  touch "$BASE16_256_FILE" && export BASE16_SHELL_SET_256COLORSPACE=1 ;;
                off) rm -f "$BASE16_256_FILE"; unset BASE16_SHELL_SET_256COLORSPACE ;;
                status)
                    [[ -f "$BASE16_256_FILE" ]] && echo "base16 256 colorspace is on" || echo "base16 256 colorspace is off"
                    return
                    ;;
                *)   echo "usage: base16 256 {on|off|status}" >&2; return 1 ;;
            esac
            # Re-source the active theme so the change applies to this shell now.
            [[ -n "$BASE16_THEME" ]] && type set_theme >/dev/null 2>&1 && set_theme "$BASE16_THEME" true
            ;;
        *)
            echo "usage: base16 {on|off|status|256 {on|off|status}}" >&2
            return 1
            ;;
    esac
}

if [[ -f "$BASE16_ENABLED_FILE" && -z $TERM_PROGRAM && (! $TTY =~ "tty" || -n $WSL_DISTRO_NAME) ]]; then
    if [[ -n "$PS1" && -s $BASE16_SHELL/profile_helper.sh ]]; then
        # Pin tinted-shell's path, keep its bundled hooks off by pointing the hook
        # dir at an uncreated path (parity with the old base16-shell, which ran
        # none; the stock hooks self-guard to no-ops unless tinted-tmux/-fzf/-vim
        # are installed, but this avoids writing unused theme files on each switch).
        # Default to eighties and honour the slot 16-21 marker file.
        export BASE16_SHELL_PATH="$BASE16_SHELL"
        export BASE16_SHELL_HOOKS_PATH="$DOTFILES/base16-shell/hooks"
        export BASE16_THEME_DEFAULT=eighties
        [[ -f "$BASE16_256_FILE" ]] && export BASE16_SHELL_SET_256COLORSPACE=1
        source "$BASE16_SHELL/profile_helper.sh"
        [[ -z "$BASE16_THEME" ]] && base16_eighties
    fi
fi
