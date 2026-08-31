#Requires -Version 7.0

# Installs command-line utilities via winget on Windows. Linux/WSL use install.sh.

$ErrorActionPreference = 'Continue'

if (-not $IsWindows) {
    return
}

. (Join-Path $PSScriptRoot '..' 'powershell' 'lib' 'winget.ps1')

Install-WingetPackage -Id 'BurntSushi.ripgrep.MSVC' -Command 'rg' -Name 'ripgrep'
Install-WingetPackage -Id 'jqlang.jq' -Command 'jq'
