#!/usr/bin/env bash

# The .sh suffix keeps this out of both runtime fragment loaders.
# Keep the source's .ps1 suffix so it can be dot-sourced directly.
local profile_src="$DOTFILES_ROOT/powershell/config/powershell/profile.ps1"
local profile_dst="$HOME/.config/powershell/profile.ps1"

mkdir -p "$(dirname "$profile_dst")"
link_file "$profile_src" "$profile_dst"
