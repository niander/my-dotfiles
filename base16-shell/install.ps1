#Requires -Version 7.0
# Clone tinted-shell themes into .base16-shell for the PowerShell loader.
# Called by script/install.ps1; existing checkouts are left alone.
# The Linux/WSL installer manages updates and ANSI-256 patches.

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
