# Use `hub` as our git wrapper if available:
#   https://hub.github.com/
if (( $+commands[hub] )); then
  hub_path=$(command -v hub)
  alias git="$hub_path"
fi

# Most short git aliases (gl, gp, gst, gd, gc, gco, gb, gca, glog, ...) come
# from the oh-my-zsh `git` plugin loaded later via oh-my-zsh/completion.zsh.
# Only define names the plugin doesn't, so these survive load order.
alias gac='git add --all && git commit -m'
alias gcpb='git copy-branch-name'
alias gcb='git copy-branch-name'
alias ge='git-edit-new'
