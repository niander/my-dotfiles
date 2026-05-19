# Atuin shell history — loaded here (under oh-my-zsh/custom) so it initializes
# AFTER oh-my-zsh plugins like zsh-autosuggestions, which is what atuin's docs
# recommend to avoid keybinding conflicts.
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi
