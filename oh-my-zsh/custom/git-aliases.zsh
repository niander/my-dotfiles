# Git aliases — placed in oh-my-zsh/custom so they load AFTER the git plugin
# (otherwise the plugin's defaults would override these).

# Overrides of oh-my-zsh git plugin defaults
alias gl='git pull --prune'              # was: git pull
alias gp='git push origin HEAD'          # was: git push
alias gs='git status -sb'                # was: git status

# Additions
alias gac='git add --all && git commit -m'
alias gcpb='git copy-branch-name'
alias gcb='git copy-branch-name'
alias ge='git-edit-new'

# Pretty graph log
alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
