#Requires -Version 7.0

# Installs delta (the pager gitconfig sets for core.pager) via winget on Windows.
# Run by script/install.ps1.

$ErrorActionPreference = 'Continue'

. (Join-Path $PSScriptRoot '..' 'powershell' 'lib' 'winget.ps1')

if ($IsWindows) {
    Install-WingetPackage -Id 'dandavison.delta' -Command 'delta'
}
elseif (-not (Get-Command delta -ErrorAction SilentlyContinue)) {
    Write-Warning "delta not found; install it with the system package manager (Debian/Ubuntu: git-delta)"
}
