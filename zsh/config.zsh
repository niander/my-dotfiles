## Functions
fpath=($DOTFILES/functions $fpath)
autoload -U $DOTFILES/functions/*(:t)

## History
[[ -z "$HISTFILE" ]] && HISTFILE="$HOME/.zsh_history"
# zsh preseeds HISTSIZE to 30 and SAVEHIST to 0, so an emptiness guard never fires.
# The gap between them is the room HIST_EXPIRE_DUPS_FIRST culls duplicates in.
HISTSIZE=70000
SAVEHIST=50000

## Options
# don't nice background tasks
setopt NO_BG_NICE
setopt NO_LIST_BEEP

# expand history before executing
setopt HIST_VERIFY
# add timestamps to history
setopt EXTENDED_HISTORY
# adds history incrementally and share it across sessions
setopt SHARE_HISTORY
# don't record a command that repeats the one before it
setopt HIST_IGNORE_DUPS
# when the history overflows, drop duplicates before unique commands
setopt HIST_EXPIRE_DUPS_FIRST
# a leading space keeps a command out of the history
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
# trim extra blanks
setopt HIST_REDUCE_BLANKS

setopt PROMPT_SUBST
setopt COMPLETE_IN_WORD
# don't expand aliases _before_ completion has finished
#   like: git comm-[tab]
setopt complete_aliases

## Key bindings
autoload -U insert-files
zle -N insert-files
bindkey '^Xf' insert-files
