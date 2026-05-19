# Use `hub` as our git wrapper if available:
#   https://hub.github.com/
if (( $+commands[hub] )); then
  alias git=$(which hub)
fi

# Pull / push / status
alias gl='git pull --prune'
alias gp='git push origin HEAD'
alias gs='git status -sb'

# Pretty log
alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"

# Diff: strip leading +/- markers, rely on color, page with less.
# Disabled by default; uncomment if you prefer it over plain `git diff`.
#alias gd='git diff --color | sed "s/^\([^-+ ]*\)[-+ ]/\\1/" | less -r'
alias gd='git diff'

# Commit
alias gc='git commit'
alias gca='git commit -a'
alias gac='git add --all && git commit -m'

# Branch / checkout
alias gb='git branch'
alias gco='git checkout'
alias gcpb='git copy-branch-name'
alias gcb='git copy-branch-name'

# New file workflow
alias ge='git-edit-new'
