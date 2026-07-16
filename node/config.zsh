export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

if [[ -s "$NVM_DIR/nvm.sh" ]]
then
    source "$NVM_DIR/nvm.sh"

    _dotfiles_nvmrc_path=
    _dotfiles_nvm_default_warning=
    typeset -A _dotfiles_corepack_warnings

    _dotfiles_enable_corepack_pnpm() {
        [[ -n "${NVM_BIN:-}" && ! -x "$NVM_BIN/pnpm" ]] || return

        local node_version
        node_version="$(nvm current)"

        if [[ -x "$NVM_BIN/corepack" ]]
        then
            if ! "$NVM_BIN/corepack" enable --install-directory "$NVM_BIN" pnpm
            then
                print -u2 "Failed to enable pnpm through Corepack for Node $node_version."
                return
            fi
            rehash
        elif [[ -z "${_dotfiles_corepack_warnings[$node_version]:-}" ]]
        then
            print -u2 "Corepack is unavailable for Node $node_version; run 'npm install --global corepack' before using pnpm."
            _dotfiles_corepack_warnings[$node_version]=1
        fi
    }

    _dotfiles_load_nvmrc() {
        local nvmrc_path
        nvmrc_path="$(nvm_find_nvmrc)"

        if [[ -n "$nvmrc_path" ]]
        then
            local previous_nvmrc_path="$_dotfiles_nvmrc_path"
            local requested_version
            local resolved_version

            _dotfiles_nvmrc_path="$nvmrc_path"
            requested_version="$(nvm_process_nvmrc "$nvmrc_path")" || return
            resolved_version="$(nvm version "$requested_version")"

            if [[ "$resolved_version" == "N/A" ]]
            then
                if [[ "$nvmrc_path" != "$previous_nvmrc_path" ]]
                then
                    print -u2 "Node $requested_version is not installed; run 'nvm install' in ${nvmrc_path:h}."
                fi
                return
            fi

            if [[ "$resolved_version" != "$(nvm current)" ]]
            then
                nvm use --silent "$requested_version" || return
            fi

            _dotfiles_enable_corepack_pnpm
        elif [[ -n "$_dotfiles_nvmrc_path" ]]
        then
            local default_version
            default_version="$(nvm version default)"

            if [[ "$default_version" == "N/A" ]]
            then
                if [[ -z "$_dotfiles_nvm_default_warning" ]]
                then
                    print -u2 "No default Node version is configured; run 'nvm alias default <version>'."
                    _dotfiles_nvm_default_warning=1
                fi
                return
            fi

            if [[ "$default_version" != "$(nvm current)" ]]
            then
                nvm use --silent default || return
            fi

            _dotfiles_nvmrc_path=
            _dotfiles_enable_corepack_pnpm
        else
            _dotfiles_enable_corepack_pnpm
        fi
    }

    autoload -Uz add-zsh-hook
    add-zsh-hook chpwd _dotfiles_load_nvmrc
    _dotfiles_load_nvmrc
fi
