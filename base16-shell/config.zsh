BASE16_SHELL=$DOTFILES/base16-shell/.base16-shell
BASE16_ENABLED_FILE=$DOTFILES/base16-shell/.base16_enabled

function base16() {
    case "$1" in
        on)
            touch "$BASE16_ENABLED_FILE" || return
            source "$BASE16_SHELL/profile_helper.sh"
            [[ -z "$BASE16_THEME" ]] && base16_eighties
            ;;
        off)
            rm -f "$BASE16_ENABLED_FILE" "$HOME/.base16_theme"
            unset BASE16_THEME
            command reset
            ;;
        status)
            [[ -f "$BASE16_ENABLED_FILE" ]] && echo "base16 is on" || echo "base16 is off"
            ;;
        *)
            echo "usage: base16 {on|off|status}" >&2
            return 1
            ;;
    esac
}

if [[ -f "$BASE16_ENABLED_FILE" && -z $TERM_PROGRAM && (! $TTY =~ "tty" || -n $WSL_DISTRO_NAME) ]]; then
    [[ -n "$PS1" ]] && [[ -s $BASE16_SHELL/profile_helper.sh ]] && source "$BASE16_SHELL/profile_helper.sh"
    [[ -z "$BASE16_THEME" ]] && base16_eighties
fi
