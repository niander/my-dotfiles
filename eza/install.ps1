#Requires -Version 7.0

# Installs eza (a modern ls) via winget on Windows, and fetches its PowerShell
# completion fresh from upstream. Run by script/install.ps1.

$ErrorActionPreference = 'Continue'

if (-not (Get-Command eza -ErrorAction SilentlyContinue)) {
    if ($IsWindows -and (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "install  eza (winget) ..."
        winget install --id eza-community.eza --source winget --accept-source-agreements --accept-package-agreements
    }
    elseif ($IsWindows) {
        Write-Warning "winget not found; install eza manually"
    }
    else {
        Write-Warning "eza not found; on Linux/WSL run script/install (bash) to install it"
    }
}

# The pwsh profile dot-sources this fragment; fetch it fresh so it tracks the
# installed eza. Non-fatal -- listings work without completion.
if (Get-Command eza -ErrorAction SilentlyContinue) {
    $dest = Join-Path $PSScriptRoot '_eza.ps1'
    try {
        Invoke-WebRequest 'https://raw.githubusercontent.com/eza-community/eza/main/completions/pwsh/_eza.ps1' -OutFile $dest -UseBasicParsing
        Write-Host "ok       eza pwsh completion"
    }
    catch {
        Write-Warning "eza pwsh completion fetch failed: $($_.Exception.Message)"
    }
}
