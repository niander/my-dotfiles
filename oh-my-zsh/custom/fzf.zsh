# fzf key bindings (Ctrl+R history, Ctrl+T files, Alt+C cd) and **<Tab>
# completion. Must load from here rather than the fzf topic: sourced any earlier,
# oh-my-zsh's startup leaves Ctrl+R on zsh's default incremental history search.
# `fzf --zsh` exists from 0.48 on; older builds ship separate files instead.
if (( $+commands[fzf] ))
then
    source <(fzf --zsh)
fi
