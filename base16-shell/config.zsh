BASE16_SHELL=$DOTFILES/base16-shell/.base16-shell
should_apply_base16=false
if [[ -z $TERM_PROGRAM && (! $TTY =~ "tty" || -n $WSL_DISTRO_NAME) ]]; then
    should_apply_base16=true
    [[ -n "$PS1" ]] && [[ -s $BASE16_SHELL/profile_helper.sh ]] && source "$BASE16_SHELL/profile_helper.sh"
fi
$should_apply_base16 && [[ -z "$BASE16_THEME" ]] && base16_eighties
