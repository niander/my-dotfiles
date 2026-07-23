BASE16_SHELL=$DOTFILES/base16-shell/.base16-shell
BASE16_ENABLED_FILE=$DOTFILES/base16-shell/.base16_enabled
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
            # Persisted toggle for base16's ANSI-256 slot 16-21 remap; off keeps index 16 = black (see install.sh).
            case "$2" in
                on)  touch "$BASE16_256_FILE" && export BASE16_SHELL_SET_256COLORSPACE=1 ;;
                off) rm -f "$BASE16_256_FILE"; unset BASE16_SHELL_SET_256COLORSPACE ;;
                status)
                    [[ -f "$BASE16_256_FILE" ]] && echo "base16 256 colorspace is on" || echo "base16 256 colorspace is off"
                    return
                    ;;
                *)   echo "usage: base16 256 {on|off|status}" >&2; return 1 ;;
            esac
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
        # tinted-shell: keep its bundled hooks off (uncreated dir), default to eighties, honour the 256 marker.
        export BASE16_SHELL_PATH="$BASE16_SHELL"
        export BASE16_SHELL_HOOKS_PATH="$DOTFILES/base16-shell/hooks"
        export BASE16_THEME_DEFAULT=eighties
        [[ -f "$BASE16_256_FILE" ]] && export BASE16_SHELL_SET_256COLORSPACE=1
        source "$BASE16_SHELL/profile_helper.sh"
        [[ -z "$BASE16_THEME" ]] && base16_eighties
    fi
fi
