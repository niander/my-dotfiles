# Route listing aliases through eza (a modern ls) when it is installed. Flags
# are eza-native -- ls's -F/-t/-s are not accepted by eza. Bare `ls` is left
# alone: the common-aliases plugin defines lS/lart/lrt/lsr in terms of `ls`, and
# aliasing ls to eza would re-expand those onto incompatible flags.
#
# This lives in the oh-my-zsh custom dir (not a top-level topic) because custom
# files load after plugins and base aliases, so these overrides take effect.
if (( $+commands[eza] )); then
    export EZA_COLORS="da=0" # date in default color
    alias l='eza -la --smart-group'
    alias la='eza -la --smart-group'
    alias ll='eza -l --smart-group'
    alias lt='eza -l --smart-group --sort=modified --reverse' # newest first
    alias lr='eza -l --smart-group -R'
    alias lsr='eza -la --smart-group -R'
    alias lsn='eza -1'
    alias lS='eza -l --smart-group --sort=size --reverse' # biggest first
    alias ldot='eza -ld --smart-group .*' # hidden only
    alias ltree='eza --tree' # --level=N to limit depth
fi
