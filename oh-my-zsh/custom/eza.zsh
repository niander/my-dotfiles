# Route listing aliases through eza (a modern ls) when it is installed. Flags
# are eza-native -- ls's -F/-t/-s are not accepted by eza. Bare `ls` is left
# alone: the common-aliases plugin defines lS/lart/lrt/lsr in terms of `ls`, and
# aliasing ls to eza would re-expand those onto incompatible flags.
#
# This lives in the oh-my-zsh custom dir (not a top-level topic) because custom
# files load after plugins and base aliases, so these overrides take effect.
if (( $+commands[eza] )); then
    alias l='eza -la'
    alias la='eza -la'
    alias ll='eza -l'
    alias lt='eza -l --sort=modified --reverse'   # newest first
    alias lr='eza -l -R'
    alias lsr='eza -la -R'
    alias lsn='eza -1'
    alias lS='eza -l --sort=size --reverse' # biggest first
    alias ldot='eza -ld .*' # hidden only
    alias ltree='eza --tree'                       # --level=N to limit depth
fi
