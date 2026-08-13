#Requires -Version 7.0

# Installs eza (a modern ls) via winget on Windows, and fetches its PowerShell
# completion fresh from upstream. Run by script/install.ps1.

$ErrorActionPreference = 'Continue'

. (Join-Path $PSScriptRoot '..' 'powershell' 'lib' 'winget.ps1')

if ($IsWindows) {
    Install-WingetPackage -Id 'eza-community.eza' -Command 'eza'
}
elseif (-not (Get-Command eza -ErrorAction SilentlyContinue)) {
    Write-Warning "eza not found; on Linux/WSL run script/install (bash) to install it"
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
