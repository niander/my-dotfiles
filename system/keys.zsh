# Pipe my public key to my clipboard.
if (( $+functions[clipcopy] )); then
    alias pubkey="cat ~/.ssh/id_rsa.pub | clipcopy | echo '=> Public key copied to pasteboard.'"
fi
