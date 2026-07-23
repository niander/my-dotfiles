BASE16_SHELL=$DOTFILES/base16-shell/.base16-shell
BASE16_ENABLED_FILE=$DOTFILES/base16-shell/.base16_enabled
BASE16_256_FILE=$DOTFILES/base16-shell/.base16_256colorspace

# base16's 256-colorspace remap overwrites ANSI slots 16-21 (index 16 -> base09
# orange, which TUIs read as black). Skipping the remap leaves an already-remapped
# terminal untouched, so restore xterm's default 6x6x6 cube values for 16-21 --
# this lets `base16 256 off` take effect live without a `reset`. Mirrors the
# vendored put_template: writes OSC 4 to the tty, wrapped for tmux passthrough.
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
            # Persisted toggle for base16's ANSI-256 slot 16-21 remap. Off restores
            # index 16 = black for TUIs like Claude Code (base16 remaps it to base09
            # orange). Applies to this terminal and to new shells. See install.sh.
            case "$2" in
                on)  touch "$BASE16_256_FILE" && export BASE16_SHELL_SET_256COLORSPACE=1 ;;
                off) rm -f "$BASE16_256_FILE"; unset BASE16_SHELL_SET_256COLORSPACE ;;
                status)
                    [[ -f "$BASE16_256_FILE" ]] && echo "base16 256 colorspace is on" || echo "base16 256 colorspace is off"
                    return
                    ;;
                *)   echo "usage: base16 256 {on|off|status}" >&2; return 1 ;;
            esac
            # Repaint the theme so 'on' sets slots 16-21; 'off' skips them, so
            # actively restore the 256-cube defaults afterward.
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

# Skip GUI terminals that manage their own colors (VSCode, etc.), but allow tmux
# -- tmux >=3.2 sets TERM_PROGRAM=tmux yet is just a multiplexer, not a GUI.
if [[ -f "$BASE16_ENABLED_FILE" && ( -z $TERM_PROGRAM || $TERM_PROGRAM == tmux ) && (! $TTY =~ "tty" || -n $WSL_DISTRO_NAME) ]]; then
    if [[ -n "$PS1" && -s $BASE16_SHELL/profile_helper.sh ]]; then
        # tinted-shell: keep its bundled hooks off (uncreated dir), default to eighties, honour the 256 marker.
        export BASE16_SHELL_PATH="$BASE16_SHELL"
        export BASE16_SHELL_HOOKS_PATH="$DOTFILES/base16-shell/hooks"
        export BASE16_THEME_DEFAULT=eighties
        [[ -f "$BASE16_256_FILE" ]] && export BASE16_SHELL_SET_256COLORSPACE=1 || unset BASE16_SHELL_SET_256COLORSPACE
        source "$BASE16_SHELL/profile_helper.sh"
        [[ -z "$BASE16_THEME" ]] && base16_eighties
        [[ -f "$BASE16_256_FILE" ]] || _base16_reset_256colorspace
    fi
fi
