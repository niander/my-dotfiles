#!/bin/sh

set -e

NVM_VERSION=v0.40.6
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
export NVM_DIR

installed_nvm_version=
if [ -s "$NVM_DIR/nvm.sh" ]
then
    installed_nvm_version="$(
        bash -c '. "$NVM_DIR/nvm.sh" --no-use && nvm --version'
    )" || installed_nvm_version=
fi

if [ "$installed_nvm_version" = "${NVM_VERSION#v}" ]
then
    exit 0
fi

nvm_installer="$(mktemp)"
trap 'rm -f "$nvm_installer"' 0 HUP INT TERM

curl -fsSL -o "$nvm_installer" \
    "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh"
PROFILE=/dev/null bash "$nvm_installer"
