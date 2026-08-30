#Requires -Version 7.0

$ErrorActionPreference = 'Stop'

if (-not $IsWindows) {
    throw 'script/provision.ps1 is for Windows hosts.'
}

$LocalRoot = if ($env:DOTFILES_LOCAL) {
    $env:DOTFILES_LOCAL
}
else {
    Join-Path $HOME '.dotfiles.local'
}
$env:DOTFILES_LOCAL = $LocalRoot

$privateProvisioner = Join-Path $LocalRoot 'script/provision.ps1'
if (-not (Test-Path -LiteralPath $privateProvisioner -PathType Leaf)) {
    Write-Host 'skip     private provisioner not found'
    return
}

Write-Host '== private/provision'
$powerShell = Join-Path $PSHOME 'pwsh.exe'
& $powerShell -NoLogo -NoProfile -File $privateProvisioner
if ($LASTEXITCODE -ne 0) {
    throw "private provisioner failed (exit $LASTEXITCODE)"
}
