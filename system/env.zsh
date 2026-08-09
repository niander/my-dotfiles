if (( $+commands[code] ))
then
    export EDITOR=code
else
    export EDITOR=vim
fi

if [[ -n "${WT_SESSION:-}" ]]
then
    export COLORTERM=truecolor
fi

if (( $+commands[less] ))
then
    less_version=$(less -V | grep -Eo 'less [0-9]+' | grep -Eo '[0-9]+')
    [[ $less_version -ge 551 ]] && export LESS="--mouse -R"
    unset less_version
fi

# Enables opening host browser when running in WSL
if [[ -n "$WSL_DISTRO_NAME" ]]
then
    export BROWSER=xdg-open
fi