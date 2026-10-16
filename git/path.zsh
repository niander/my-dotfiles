# Git Credential Manager Core. The store is per-OS: secretservice is the
# Linux freedesktop store, while macOS uses the Keychain.
if [[ "$(uname -s)" == Darwin ]]
then
    export GCM_CREDENTIAL_STORE=keychain
else
    export GCM_CREDENTIAL_STORE=secretservice
fi
export GPG_TTY=$TTY