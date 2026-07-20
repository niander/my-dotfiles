# uv / uvx shell completion.
# Sourced after compinit (see zshrc.symlink), which the generated
# `compdef` calls require.
if (( $+commands[uv] ))
then
    eval "$(uv generate-shell-completion zsh)"
    eval "$(uvx --generate-shell-completion zsh)"
fi
