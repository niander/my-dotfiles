# Must load before omz: its rust plugin returns early unless cargo and rustup resolve.
if [[ -d "$HOME/.cargo/bin" ]]
then
    export PATH="$HOME/.cargo/bin:$PATH"
fi
