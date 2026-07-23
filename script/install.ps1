#Requires -Version 7.0
# Runs each topic's install.ps1. Cross-platform (WSL2, Windows, macOS).
# Idempotent -- topics guard their own work.

$ErrorActionPreference = 'Continue'

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

foreach ($topic in Get-ChildItem -LiteralPath $RepoRoot -Directory) {
    if ($topic.Name -eq 'script') { continue }
    $installer = Join-Path $topic.FullName 'install.ps1'
    if (Test-Path $installer) {
        Write-Host "== $($topic.Name)"
        & $installer
    }
}
