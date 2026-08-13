#Requires -Version 7.0

# Installs Node.js LTS (including npm) and pnpm on Windows.
# Linux/WSL use install.sh and nvm instead.

$ErrorActionPreference = 'Continue'

if (-not $IsWindows) {
    return
}

. (Join-Path $PSScriptRoot '..' 'powershell' 'lib' 'winget.ps1')

Install-WingetPackage -Id 'OpenJS.NodeJS.LTS' -Command 'node' -Name 'Node.js LTS'

if (Get-Command npm -ErrorAction SilentlyContinue) {
    Write-Host 'ok       npm already installed'
}
elseif (Get-Command node -ErrorAction SilentlyContinue) {
    Write-Warning 'npm not found; repair or reinstall the active Node.js version'
}
else {
    Write-Warning 'npm will be available after Node.js LTS is installed; open a new shell afterward'
}

Install-WingetPackage -Id 'pnpm.pnpm' -Command 'pnpm'
