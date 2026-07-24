#Requires -Version 7.0
# Clones the tinted-shell theme scripts into .base16-shell so the PowerShell
# base16 loader has themes to read. Run by script/install.ps1. Idempotent:
# only clones when the checkout is missing.
#
# On Linux/WSL a sibling bash installer owns updates and additionally patches
# the theme scripts' ANSI-256 slots; a hard reset here would discard that patch
# on a shared checkout, so this step never touches an existing clone. The
# PowerShell loader gates the 256-color slots itself at runtime, so the raw
# scripts are enough on hosts that only ever run this installer.

$ErrorActionPreference = 'Continue'

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Warning "git not found; skipping base16 theme download"
    return
}

$base16Shell = Join-Path $PSScriptRoot '.base16-shell'
$remote = 'https://github.com/tinted-theming/tinted-shell.git'

if (Test-Path (Join-Path $base16Shell '.git')) {
    Write-Host "ok       base16 themes already present"
    return
}

Write-Host "clone    tinted-shell (base16 themes) ..."
git clone --quiet $remote $base16Shell
