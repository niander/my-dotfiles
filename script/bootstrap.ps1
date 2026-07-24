#Requires -Version 7.0
<#
.SYNOPSIS
Windows PowerShell bootstrap for niander/my-dotfiles.

.DESCRIPTION
Sets up the PowerShell profile on a Windows host. Run from a PowerShell 7
window (Developer Mode or an elevated shell is required to create the symlink):

    .\script\bootstrap.ps1

On WSL/Linux use script/bootstrap (bash) instead -- this only wires up the
PowerShell side (profile + tooling), not zsh/tmux/git.

It:
  1. links ~/.dotfiles to this checkout (a symbolic link; fails if it can't)
  2. symlinks this repo's profile in as your all-hosts profile.ps1 (any
     existing profile.ps1 is backed up)
  3. runs install.ps1 (oh-my-posh + fzf via winget, PS module starter pack)
#>

$ErrorActionPreference = 'Stop'

# Windows-only: on Linux/WSL the bash script/bootstrap owns this, and running
# here would double-wire the profile (the ~/.config/powershell profile is
# already symlinked to the repo there).
if (-not $IsWindows) {
    throw 'script/bootstrap.ps1 is for Windows hosts. On Linux/WSL run script/bootstrap (bash).'
}

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

# --- ~/.dotfiles symlink ---------------------------------------------------
$dotfilesLink = Join-Path $HOME '.dotfiles'
$existingLink = Get-Item -LiteralPath $dotfilesLink -Force -ErrorAction SilentlyContinue
if ($existingLink) {
    if ($existingLink.LinkType -ne 'SymbolicLink') {
        throw "~/.dotfiles exists but is not a symbolic link. Remove it, then re-run."
    }
    $resolved = (Resolve-Path -LiteralPath $existingLink.Target -ErrorAction SilentlyContinue).Path
    if ($resolved -eq $RepoRoot) {
        Write-Host "ok    ~/.dotfiles already links to this checkout"
    }
    else {
        throw "~/.dotfiles points to '$($existingLink.Target)', not '$RepoRoot'. Remove it or repoint it, then re-run."
    }
}
else {
    try {
        New-Item -ItemType SymbolicLink -Path $dotfilesLink -Target $RepoRoot | Out-Null
        Write-Host "link  ~/.dotfiles -> $RepoRoot"
    }
    catch {
        Write-Warning "Creating a symbolic link requires Developer Mode (Settings > System > For developers) or an elevated PowerShell."
        throw
    }
}

# --- profile.ps1 symlink ---------------------------------------------------
# CurrentUserAllHosts is profile.ps1
$profilePath = $PROFILE.CurrentUserAllHosts
$profileTarget = Join-Path $RepoRoot 'powershell/config/powershell/profile.ps1.symlink'
$profileDir = Split-Path -Parent $profilePath
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }

$alreadyLinked = $false
if (Test-Path $profilePath) {
    $target = (Get-Item $profilePath -Force).Target
    $resolvedTarget = if ($target) { (Resolve-Path -LiteralPath $target -ErrorAction SilentlyContinue).Path }
    if ($resolvedTarget -and ($resolvedTarget -eq (Resolve-Path -LiteralPath $profileTarget).Path)) {
        $alreadyLinked = $true
    }
}

if ($alreadyLinked) {
    Write-Host "ok    profile.ps1 already links to the repo profile"
}
else {
    if (Test-Path $profilePath) {
        $backup = "$profilePath.backup"
        if (Test-Path $backup) { $backup = "$profilePath.backup-$(Get-Date -Format 'yyyyMMddHHmmss')" }
        Move-Item -LiteralPath $profilePath -Destination $backup -Force
        Write-Warning "Backed up existing profile.ps1 -> $backup. Move machine-specific lines (e.g. conda init) into ~/.localprofile.ps1; conda now loads via the miniconda/ topic."
    }
    try {
        New-Item -ItemType SymbolicLink -Path $profilePath -Target $profileTarget | Out-Null
        Write-Host "link  profile.ps1 -> $profileTarget"
    }
    catch {
        Write-Warning "Creating a symbolic link requires Developer Mode (Settings > System > For developers) or an elevated PowerShell."
        throw
    }
}

# --- install tooling -------------------------------------------------------
& (Join-Path $PSScriptRoot 'install.ps1')

Write-Host ''
Write-Host 'Done. Open a new PowerShell 7 window to load the profile.'
