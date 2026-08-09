# Overrides -fast-highlight-main-type from fast-syntax-highlighting
# https://github.com/zdharma-continuum/fast-syntax-highlighting/blob/master/fast-highlight
#
# Replaces the `type -w` fallback with a $PATH walk that skips drive-letter mounts,
# where a stat crosses into the Windows filesystem and costs milliseconds.
# It runs once per keystroke per command word: the plugin clears its type cache on every buffer change.
# Filtering `path` around the original instead is slower — assigning to it drops the command hash table.
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
        elif [[ $1 == */* ]]; then
            # $commands holds PATH-resolved names only; explicit paths need a direct test.
            [[ -x $1 && ! -d $1 ]] && REPLY=command || REPLY=none
        else
            REPLY=none
            # $commands is a snapshot of the last hash,
            # so a binary dropped into a directory already on $PATH stays missing from it until a rehash.
            local path_dir
            for path_dir in ${path:#/mnt/[a-zA-Z](|/*)}; do
                [[ -x $path_dir/$1 && ! -d $path_dir/$1 ]] && { REPLY=command; break; }
            done
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
