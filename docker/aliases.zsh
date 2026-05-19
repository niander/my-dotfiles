if (( $+commands[docker] )); then
  alias d='docker'
fi

if (( $+commands[docker-compose] )); then
  alias d-c='docker-compose'
elif (( $+commands[docker] )); then
  # newer docker exposes compose as a subcommand
  alias d-c='docker compose'
fi
