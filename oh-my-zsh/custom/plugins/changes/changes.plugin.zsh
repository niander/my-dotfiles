# Changes for the plugin tmux
# Author: niander

if which tmux &> /dev/null
	then
	function _zsh_tmux_plugin_run()
        {
                # We have other arguments, just run them
                if [[ -n "$@" ]]
                then
                        \tmux $@
                # Try to connect to an existing session.
                elif [[ "$ZSH_TMUX_AUTOCONNECT" == "true" ]]
                then
                        \tmux `[[ "$ZSH_TMUX_ITERM2" == "true" ]] && echo '-CC '` attach || \tmux `[[ "$ZSH_TMUX_ITERM2" == "true" ]] && echo '-CC '` `[[ "$ZSH_TMUX_FIXTERM" == "true" ]] && echo '-f '$_ZSH_TMUX_FIXED_CONFIG` new-session -s main
                        [[ "$ZSH_TMUX_AUTOQUIT" == "true" ]] && exit
                # Just run tmux, fixing the TERM variable if requested.
                else
                        \tmux `[[ "$ZSH_TMUX_ITERM2" == "true" ]] && echo '-CC '` `[[ "$ZSH_TMUX_FIXTERM" == "true" ]] && echo '-f '$_ZSH_TMUX_FIXED_CONFIG`
                        [[ "$ZSH_TMUX_AUTOQUIT" == "true" ]] && exit
                fi
        }

	compdef _tmux _zsh_tmux_plugin_run

	alias tmux=_zsh_tmux_plugin_run
fi

# Params
ZSH_TMUX_AUTOSTART=false

# zsh_autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=history
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

