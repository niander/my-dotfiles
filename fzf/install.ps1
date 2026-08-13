#Requires -Version 7.0

# Installs fzf via winget on Windows. Linux/WSL use install.sh.

$ErrorActionPreference = 'Continue'

if (-not $IsWindows) {
    return
}

. (Join-Path $PSScriptRoot '..' 'powershell' 'lib' 'winget.ps1')

Install-WingetPackage -Id 'junegunn.fzf' -Command 'fzf'
