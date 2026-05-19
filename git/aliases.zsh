# Use `hub` as our git wrapper if available:
#   https://hub.github.com/
hub_path=$(which hub)
if (( $+commands[hub] ))
then
  alias git=$hub_path
fi

# NOTE: most git aliases (gl, gp, gd, gs, gc, gco, gb, gca, glog, ...) come from
# the oh-my-zsh `git` plugin loaded later. Overrides and additions live in
# oh-my-zsh/custom/git-aliases.zsh so they take effect after the plugin.
