# Modifications from robbyrussell theme

local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
PROMPT='${ret_status}%{$reset_color%} %{$fg[yellow]%}%~%{$reset_color%} \
$(git_prompt_info)\
%(!.#.$) '
PROMPT2='%F{green}(%_)%f %F{yellow}\%f '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[cyan]%}git:("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="*"
ZSH_THEME_GIT_PROMPT_CLEAN=""
