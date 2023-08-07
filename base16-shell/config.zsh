BASE16_SHELL=$DOTFILES/base16-shell/.base16-shell
if [[ -z $TERM_PROGRAM && (! $TTY =~ "tty" || ! -z $WSL_DISTRO_NAME) ]]; then
    [[ -n "$PS1" ]] && [[ -s $BASE16_SHELL/profile_helper.sh ]] && source "$BASE16_SHELL/profile_helper.sh"
    [[ -z "$BASE16_THEME" ]] && base16_eighties
fi
