# Default editor — only set if the user/machine hasn't picked one already.
# Per-machine overrides go in ~/.localrc.
if [[ -z "$EDITOR" ]]; then
  export EDITOR='vim'
fi
if [[ -z "$VISUAL" ]]; then
  export VISUAL="$EDITOR"
fi
