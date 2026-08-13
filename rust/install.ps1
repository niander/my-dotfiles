#Requires -Version 7.0

# Installs rustup and the default Rust toolchain on Windows.

$ErrorActionPreference = 'Continue'

if (-not $IsWindows) {
    return
}

. (Join-Path $PSScriptRoot '..' 'powershell' 'lib' 'winget.ps1')

Install-WingetPackage -Id 'Rustlang.Rustup' -Command 'rustup' -Override '-y'
