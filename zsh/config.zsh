#export LSCOLORS="exfxcxdxbxegedabagacad"
#export CLICOLOR=true

fpath=($DOTFILES/functions $fpath)

autoload -U $DOTFILES/functions/*(:t)

[[ -z "$HISTFILE" ]] && HISTFILE="$HOME/.zsh_history"
[[ -z "$HISTSIZE" ]] && HISTSIZE=50000
[[ -z "$SAVEHIST" ]] && SAVEHIST=10000

# don't nice background tasks
setopt NO_BG_NICE
#setopt NO_HUP
setopt NO_LIST_BEEP

# expand history before executing
setopt HIST_VERIFY
# add timestamps to history
setopt EXTENDED_HISTORY
setopt PROMPT_SUBST
setopt CORRECT
setopt COMPLETE_IN_WORD

# adds history incrementally and share it across sessions
setopt SHARE_HISTORY

# don't expand aliases _before_ completion has finished
#   like: git comm-[tab]
setopt complete_aliases

#bindkey '^[^[[D' backward-word
#bindkey '^[^[[C' forward-word
#bindkey '^[[5D' beginning-of-line
#bindkey '^[[5C' end-of-line
#bindkey '^[[3~' delete-char
#bindkey '^?' backward-delete-char
