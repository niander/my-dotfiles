#Requires -Version 7.0

# Installs delta (the pager gitconfig sets for core.pager) via winget on Windows.
# Run by script/install.ps1.

$ErrorActionPreference = 'Continue'

if (-not (Get-Command delta -ErrorAction SilentlyContinue)) {
    if ($IsWindows -and (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "install  delta (winget) ..."
        winget install --id dandavison.delta --source winget --accept-source-agreements --accept-package-agreements
    }
    elseif ($IsWindows) {
        Write-Warning "winget not found; install delta manually"
    }
    else {
        Write-Warning "delta not found; install it with the system package manager (Debian/Ubuntu: git-delta)"
    }
}
