# Adapted from oh-my-zsh's globalias plugin (MIT):
# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/globalias/globalias.plugin.zsh
# Removed `zle expand-word`. Only the alias expansion is kept here.

my-globalias() {
  # Get last word to the left of the cursor:
  # (z) splits into words using shell parsing
  # (A) makes it an array even if there's only one element
  local word=${${(Az)LBUFFER}[-1]}
  if [[ $GLOBALIAS_FILTER_VALUES[(Ie)$word] -eq 0 ]]; then
    zle _expand_alias
  fi
  zle self-insert
}
zle -N my-globalias

# space expands aliases, including global ones
bindkey -M emacs " " my-globalias
bindkey -M viins " " my-globalias

# control-space to make a normal space
bindkey -M emacs "^ " magic-space
bindkey -M viins "^ " magic-space

# normal space during searches
bindkey -M isearch " " magic-space
