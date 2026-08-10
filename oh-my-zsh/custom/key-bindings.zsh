# Remove [PageUp] and [PageDown] keybindings
if [[ "${terminfo[kpp]}" != "" ]]; then
    bindkey -r "${terminfo[kpp]}"
fi
if [[ "${terminfo[knp]}" != "" ]]; then
    bindkey -r "${terminfo[knp]}"
fi

# [Esc] [Esc] clears the whole buffer (yank it back with ^Y).
# The sudo plugin claims that chord for prefix-with-sudo; move it to [Alt] [s].
for keymap in emacs vicmd viins; do
    bindkey -M $keymap '\e\e' kill-buffer
    (( $+widgets[sudo-command-line] )) && bindkey -M $keymap '\es' sudo-command-line
done
unset keymap
