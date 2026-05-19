# NOTE: oh-my-zsh's `common-aliases` plugin defines `d='dirs -v | head -10'`
# and loads AFTER this file (oh-my-zsh/completion.zsh runs last). So we don't
# define `d` here. Use `dk` instead, or just type `docker`.
if (( $+commands[docker] )); then
  alias dk='docker'
fi

if (( $+commands[docker-compose] )); then
  alias d-c='docker-compose'
elif (( $+commands[docker] )); then
  # newer docker exposes compose as a subcommand
  alias d-c='docker compose'
fi
