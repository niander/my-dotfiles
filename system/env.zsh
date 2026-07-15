export EDITOR=code

if [[ -n "${WT_SESSION:-}" ]]
then
    export COLORTERM=truecolor
fi

if [[ -a $(which less) ]]
then
    ver=$(less -V | grep -Eo 'less [0-9]+' | grep -Eo '[0-9]+')
    [[ ver -ge 551 ]] && export LESS="--mouse -R"
fi

# Enables opening host browser when running in WSL
if [[ -n "$WSL_DISTRO_NAME" ]]
then
    export BROWSER=xdg-open
fi