#Requires -Version 7.0
# Runs each topic's install.ps1. Cross-platform (WSL2, Windows, macOS).

$ErrorActionPreference = 'Continue'

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$LocalRoot = if ($env:DOTFILES_LOCAL) {
    $env:DOTFILES_LOCAL
}
else {
    Join-Path $HOME '.dotfiles.local'
}
$env:DOTFILES_LOCAL = $LocalRoot

foreach ($topic in Get-ChildItem -LiteralPath $RepoRoot -Directory) {
    if ($topic.Name -eq 'script') { continue }
    $installer = Join-Path $topic.FullName 'install.ps1'
    if (Test-Path $installer) {
        Write-Host "== $($topic.Name)"
        & $installer
    }
}

if (Test-Path -LiteralPath $LocalRoot -PathType Container) {
    foreach ($topic in Get-ChildItem -LiteralPath $LocalRoot -Directory) {
        if ($topic.Name -eq 'script') { continue }
        $installer = Join-Path $topic.FullName 'install.ps1'
        if (-not (Test-Path -LiteralPath $installer -PathType Leaf)) { continue }

        Write-Host "== local/$($topic.Name)"
        try {
            & $installer
        }
        catch {
            Write-Warning "local installer $($topic.Name): $($_.Exception.Message)"
        }
    }
}
