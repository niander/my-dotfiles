#Requires -Version 7.0
# Prepend user-local bins to PATH.

Add-DotfilesPath (Join-Path $HOME '.local/bin')
