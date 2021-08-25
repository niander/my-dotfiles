export EDITOR=code

if [[ -a $(which less) ]]
then
    ver=$(less -V | grep -Eo 'less [0-9]+' | grep -Eo '[0-9]+')
    [[ ver -ge 551 ]] && export LESS="--mouse -R"
fi