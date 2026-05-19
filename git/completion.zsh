# Source git's zsh completion if available.
# Tries common system paths so this works on Linux, WSL, and macOS.
# If you use oh-my-zsh's git plugin, this is mostly redundant.

for _candidate in \
  "/usr/share/zsh/vendor-completions/_git" \
  "/usr/share/zsh/functions/Completion/Unix/_git" \
  "/usr/share/zsh/site-functions/_git"; do
  if [ -f "$_candidate" ]; then
    source "$_candidate"
    break
  fi
done
unset _candidate
