# Use `hub` as our git wrapper if available:
#   https://hub.github.com/
if (( $+commands[hub] )); then
  hub_path=$(command -v hub)
  alias git="$hub_path"
fi

# git aliases that the plugin git of omz doesn't provide, or that I want to override
alias gac='git add --all && git commit -m'
alias gcpb='git copy-branch-name'
alias gcb='git copy-branch-name'
alias ge='git-edit-new'
