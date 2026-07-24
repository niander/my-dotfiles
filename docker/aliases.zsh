# oh-my-zsh's `common-aliases` plugin overrides `d` after this file loads.
# Use `dk` or `docker` instead.
if (( $+commands[docker] )); then
  alias dk='docker'
fi

if (( $+commands[docker-compose] )); then
  alias d-c='docker-compose'
elif (( $+commands[docker] )); then
  # Docker Compose v2 is a Docker subcommand.
  alias d-c='docker compose'
fi
