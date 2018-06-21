# Remove [PageUp] and [PageDown] keybindings
if [[ "${terminfo[kpp]}" != "" ]]; then
    bindkey -r "${terminfo[kpp]}"
fi
if [[ "${terminfo[knp]}" != "" ]]; then
    bindkey -r "${terminfo[knp]}"
fi
