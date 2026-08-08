# clipcopy is an oh-my-zsh function, so this must load after omz — hence
# oh-my-zsh/custom/ rather than a topic folder.
if (( $+functions[clipcopy] )); then
    alias pubkey="clipcopy < ~/.ssh/id_rsa.pub && echo '=> Public key copied to clipboard.'"
fi
