# Overrides -fast-highlight-main-type from fast-syntax-highlighting
# https://github.com/zdharma-continuum/fast-syntax-highlighting/blob/master/fast-highlight
#
# Drops the slow `type -w` fallback that looks up $PATH.
# Commands added after shell initialization are not found until a reload.
if (( $+functions[-fast-highlight-main-type] )) && zmodload -e zsh/parameter
then
    -fast-highlight-main-type() {
        REPLY=$__fast_highlight_main__command_type_cache[(e)$1]
        [[ -n $REPLY ]] && return

        if (( $+aliases[(e)$1] )); then
            REPLY=alias
        elif (( ${+galiases[(e)${(Q)1}]} )); then
            REPLY="global alias"
        elif (( $+functions[(e)$1] )); then
            REPLY=function
        elif (( $+builtins[(e)$1] )); then
            REPLY=builtin
        elif (( $+commands[(e)$1] )); then
            REPLY=command
        elif (( $+saliases[(e)${1##*.}] )); then
            REPLY='suffix alias'
        elif (( $reswords[(Ie)$1] )); then
            REPLY=reserved
        elif [[ $1 == */* && -x $1 && ! -d $1 ]]; then
            # $commands holds PATH-resolved names only; explicit paths need a direct test.
            REPLY=command
        else
            REPLY=none
        fi

        [[ $REPLY = none ]] && {
            [[ -n ${FAST_BLIST_PATTERNS[(k)${${(M)1:#/*}:-$PWD/$1}]} ]] || {
                [[ -d $1 ]] && REPLY=dirpath || {
                    local cdpath_dir
                    for cdpath_dir in $cdpath; do
                        [[ -d $cdpath_dir/$1 ]] && { REPLY=dirpath; break; }
                    done
                }
            }
        }

        __fast_highlight_main__command_type_cache[(e)$1]=$REPLY
    }
fi
