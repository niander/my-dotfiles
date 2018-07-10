# inspired by robbyrussell theme

function conda_prompt_info() {
  local env=$(echo "${CONDA_DEFAULT_ENV:#base}" | tr -d "[:space:]")
  [[ -n $env ]] && ret="%F{magenta}🅒 ($env)%f " && echo "$ret"
}

function ret_status_prompt_info() {
  local prompt_symbol="➜ "
  echo "%(?:%F{green}%B$prompt_symbol :%F{red}%B$prompt_symbol )%b%f"
}

PROMPT='$(ret_status_prompt_info)$(conda_prompt_info)\
%F{yellow}%~%f \
$(git_prompt_info)\
%(!.#.$) '
PROMPT2='%F{green}(%_)%f %F{yellow}\%f '

ZSH_THEME_GIT_PROMPT_PREFIX="%F{blue} ("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%f "
ZSH_THEME_GIT_PROMPT_DIRTY="*"
ZSH_THEME_GIT_PROMPT_CLEAN=""
