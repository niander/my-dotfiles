## Colors
# ls colors on mac
[[ -z "$LSCOLORS" ]] && export LSCOLORS="exfxcxdxbxegedabagacad"
[[ -z "$CLICOLOR" ]] && export CLICOLOR=true

## Functions
fpath=($DOTFILES/functions $fpath)
autoload -U $DOTFILES/functions/*(:t)

## History
[[ -z "$HISTFILE" ]] && HISTFILE="$HOME/.zsh_history"
[[ -z "$HISTSIZE" ]] && HISTSIZE=50000
[[ -z "$SAVEHIST" ]] && SAVEHIST=10000

## Options
# don't nice background tasks
setopt NO_BG_NICE
# don't kill background jobs on shell exit
setopt NO_HUP
setopt NO_LIST_BEEP
# allow functions to have local options/traps
setopt LOCAL_OPTIONS
setopt LOCAL_TRAPS

# expand history before executing
setopt HIST_VERIFY
# add timestamps to history
setopt EXTENDED_HISTORY
# adds history incrementally and share it across sessions
# NOTE: INC_APPEND_HISTORY is intentionally NOT set here — oh-my-zsh/custom/history.zsh
# unsets it because share_history covers the same need without its drawbacks.
setopt SHARE_HISTORY
# don't record duplicate commands
setopt HIST_IGNORE_ALL_DUPS
# trim extra blanks
setopt HIST_REDUCE_BLANKS

setopt CORRECT
setopt PROMPT_SUBST
setopt COMPLETE_IN_WORD
# don't expand aliases _before_ completion has finished
#   like: git comm-[tab]
setopt complete_aliases

## Key bindings
autoload -U insert-files
zle -N insert-files
bindkey '^Xf' insert-files
