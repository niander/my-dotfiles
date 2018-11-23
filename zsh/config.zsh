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
setopt NO_LIST_BEEP

# expand history before executing
setopt HIST_VERIFY
# add timestamps to history
setopt EXTENDED_HISTORY
# adds history incrementally and share it across sessions
setopt SHARE_HISTORY

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
