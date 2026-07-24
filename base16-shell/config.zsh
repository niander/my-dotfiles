BASE16_SHELL=$DOTFILES/base16-shell/.base16-shell
BASE16_ENABLED_FILE=$DOTFILES/base16-shell/.base16_enabled
BASE16_256_FILE=$DOTFILES/base16-shell/.base16_256colorspace

# Restore xterm defaults for slots 16-21 when the remap is disabled.
function _base16_reset_256colorspace() {
    local tty=${TTY:-$(tty 2>/dev/null)}
    [[ -n $tty && -w $tty ]] || return 0
    local osc=$'\033]4;16;rgb:00/00/00;17;rgb:00/00/5f;18;rgb:00/00/87;19;rgb:00/00/af;20;rgb:00/00/d7;21;rgb:00/00/ff\033\\'
    if [[ -n $TMUX || ${TERM%%[-.]*} == tmux ]]; then
        osc=$'\033Ptmux;'${osc//$'\033'/$'\033\033'}$'\033\\'
    fi
    print -rn -- "$osc" > "$tty"
}

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
            # Persist the slot 16-21 remap setting for this and future shells.
            case "$2" in
                on)  touch "$BASE16_256_FILE" && export BASE16_SHELL_SET_256COLORSPACE=1 ;;
                off) rm -f "$BASE16_256_FILE"; unset BASE16_SHELL_SET_256COLORSPACE ;;
                status)
                    [[ -f "$BASE16_256_FILE" ]] && echo "base16 256 colorspace is on" || echo "base16 256 colorspace is off"
                    return
                    ;;
                *)   echo "usage: base16 256 {on|off|status}" >&2; return 1 ;;
            esac
            # Repaint the theme, then restore defaults when the remap is off.
            [[ -n "$BASE16_THEME" ]] && type set_theme >/dev/null 2>&1 && set_theme "$BASE16_THEME" true
            [[ -f "$BASE16_256_FILE" ]] || _base16_reset_256colorspace
            return 0
            ;;
        *)
            echo "usage: base16 {on|off|status|256 {on|off|status}}" >&2
            return 1
            ;;
    esac
}
alias base16='toggle_base16_shell'

# Skip GUI terminals that manage their own colors, but allow tmux.
if [[ -f "$BASE16_ENABLED_FILE" && ( -z $TERM_PROGRAM || $TERM_PROGRAM == tmux ) && (! $TTY =~ "tty" || -n $WSL_DISTRO_NAME) ]]; then
    if [[ -n "$PS1" && -s $BASE16_SHELL/profile_helper.sh ]]; then
        # Keep bundled hooks disabled and default to the eighties theme.
        export BASE16_SHELL_PATH="$BASE16_SHELL"
        export BASE16_SHELL_HOOKS_PATH="$DOTFILES/base16-shell/hooks"
        export BASE16_THEME_DEFAULT=eighties
        [[ -f "$BASE16_256_FILE" ]] && export BASE16_SHELL_SET_256COLORSPACE=1 || unset BASE16_SHELL_SET_256COLORSPACE
        source "$BASE16_SHELL/profile_helper.sh"
        [[ -z "$BASE16_THEME" ]] && base16_eighties
        [[ -f "$BASE16_256_FILE" ]] || _base16_reset_256colorspace
    fi
fi
