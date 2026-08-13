#Requires -Version 7.0
<#
.SYNOPSIS
Windows PowerShell bootstrap for niander/my-dotfiles.

.DESCRIPTION
Sets up a Windows host: the PowerShell profile, the git config and tooling. Run
from a PowerShell 7 window with symlink rights (Developer Mode or elevated):

    .\script\bootstrap.ps1

On WSL/Linux use script/bootstrap (bash) instead, which also covers zsh and tmux.

It:
  1. links ~/.dotfiles to this checkout (a symbolic link; fails if it can't)
  2. symlinks this repo's profile in as your all-hosts profile.ps1 (any
     existing profile.ps1 is backed up)
  3. adds an include of this repo's gitconfig to ~/.gitconfig, and symlinks
     ~/.gitignore
  4. runs install.ps1 (Node.js/npm, pnpm, shell tools and PS modules)
#>

$ErrorActionPreference = 'Stop'

# Windows-only: on Linux/WSL the bash script/bootstrap owns this, and running
# here would double-wire the profile (the ~/.config/powershell profile is
# already symlinked to the repo there).
if (-not $IsWindows) {
    throw 'script/bootstrap.ps1 is for Windows hosts. On Linux/WSL run script/bootstrap (bash).'
}

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

function Get-BackupPath {
    param([Parameter(Mandatory)][string] $Path)

    $candidate = "$Path.backup"
    if (-not (Test-Path -LiteralPath $candidate)) { return $candidate }

    $stamp = Get-Date -Format 'yyyyMMddHHmmssfff'
    $sequence = 0
    do {
        $suffix = if ($sequence) { "-$sequence" } else { '' }
        $candidate = "$Path.backup-$stamp$suffix"
        $sequence++
    } while (Test-Path -LiteralPath $candidate)

    return $candidate
}

function Resolve-LinkTarget {
    param([Parameter(Mandatory)] $Item)

    if (-not $Item.Target) { return $null }

    $target = @($Item.Target)[0]
    if (-not [System.IO.Path]::IsPathRooted($target)) {
        $target = Join-Path (Split-Path -Parent $Item.FullName) $target
    }

    return (Resolve-Path -LiteralPath $target -ErrorAction SilentlyContinue).Path
}

# Points $Path at $Target, moving anything already there aside.
function Set-Symlink {
    param(
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)][string] $Target,
        [string] $Label = (Split-Path -Leaf $Path)
    )

    $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
    $existing = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    $backup = $null

    if ($existing) {
        $current = Resolve-LinkTarget $existing
        if ($current -eq $resolvedTarget) {
            Write-Host "ok    $Label already links to the repo"
            return $false
        }
        $backup = Get-BackupPath $Path
        Move-Item -LiteralPath $Path -Destination $backup -Force
        Write-Warning "Backed up existing $Label -> $backup"
    }

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Path -Target $resolvedTarget | Out-Null
    }
    catch {
        if ($backup -and -not (Test-Path -LiteralPath $Path) -and (Test-Path -LiteralPath $backup)) {
            Move-Item -LiteralPath $backup -Destination $Path -Force
            Write-Warning "Restored $Label after the symbolic link could not be created."
        }
        Write-Warning 'Creating a symbolic link may require Developer Mode (Settings > System > For developers) or an elevated PowerShell.'
        throw
    }
    Write-Host "link  $Label -> $resolvedTarget"
    return ($null -ne $backup)
}

# Prepends the baseline to $Path so machine settings below it win. $Path is
# kept a regular file because writes follow a symlink into the checkout.
function Add-GitInclude {
    param(
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)][string] $IncludePath,
        [Parameter(Mandatory)][string] $LinkTarget
    )

    $label = Split-Path -Leaf $Path
    $body = ''
    $encoding = [System.Text.UTF8Encoding]::new($false)
    $existing = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    $symlinkBackup = $null

    if ($existing -and $existing.LinkType) {
        $target = Resolve-LinkTarget $existing
        $expectedTarget = (Resolve-Path -LiteralPath $LinkTarget).Path
        if ($target -ne $expectedTarget) {
            throw "$label links to '$($existing.Target)', not '$expectedTarget'. Remove it or migrate its settings, then re-run."
        }
        $symlinkBackup = Get-BackupPath $Path
        Move-Item -LiteralPath $Path -Destination $symlinkBackup -Force
    }
    elseif ($existing) {
        $reader = [System.IO.StreamReader]::new($Path, $encoding, $true)
        try {
            $body = $reader.ReadToEnd()
            $encoding = $reader.CurrentEncoding
        }
        finally {
            $reader.Dispose()
        }
    }

    $eol = if ($body -match "`r`n") { "`r`n" } elseif ($body -match "`n") { "`n" } else { [Environment]::NewLine }
    $block = "[include]$eol`tpath = $IncludePath$eol"
    $escapedPath = [regex]::Escape($IncludePath)
    # Drop the whole section only when our path is its sole entry, otherwise
    # just the one line; removing a header would reassign its other entries.
    $sectionPattern = "(?im)^\[include\][ \t]*\r?\n[ \t]*path[ \t]*=[ \t]*$escapedPath[ \t]*(?:\r?\n|\z)(?=[ \t]*\[|\z)"
    $linePattern = "(?im)^[ \t]*path[ \t]*=[ \t]*$escapedPath[ \t]*(?:\r?\n|\z)"
    $withoutBlock = [regex]::Replace($body, $sectionPattern, '')
    $withoutBlock = [regex]::Replace($withoutBlock, $linePattern, '')
    $newBody = "$block$withoutBlock"

    if ($newBody -eq $body) {
        Write-Host "ok    $label already includes the repo config"
        return
    }

    # Two includes would apply the baseline twice, doubling multi-valued
    # settings such as credential helpers.
    if ($withoutBlock.Contains($IncludePath)) {
        Write-Warning "$label includes $IncludePath in another form; move it to the top by hand."
        return
    }

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    try {
        $writer = [System.IO.StreamWriter]::new($Path, $false, $encoding)
        try {
            $writer.Write($newBody)
        }
        finally {
            $writer.Dispose()
        }
    }
    catch {
        if ($symlinkBackup) {
            Remove-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
            Move-Item -LiteralPath $symlinkBackup -Destination $Path -Force
        }
        throw
    }

    if ($symlinkBackup) {
        Remove-Item -LiteralPath $symlinkBackup -Force
        Write-Warning "$label was a symlink; replaced it with a file that includes the repo config."
    }
    Write-Host "add   $label -> include $IncludePath"
}

# --- ~/.dotfiles symlink ---------------------------------------------------
$dotfilesLink = Join-Path $HOME '.dotfiles'
$existingLink = Get-Item -LiteralPath $dotfilesLink -Force -ErrorAction SilentlyContinue
if ($existingLink) {
    if ($existingLink.LinkType -ne 'SymbolicLink') {
        throw "~/.dotfiles exists but is not a symbolic link. Remove it, then re-run."
    }
    $resolved = Resolve-LinkTarget $existingLink
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
$profileTarget = Join-Path $RepoRoot 'powershell/config/powershell/profile.ps1.symlink'
$profileBackedUp = Set-Symlink -Path $PROFILE.CurrentUserAllHosts -Target $profileTarget -Label 'profile.ps1'
if ($profileBackedUp) {
    Write-Warning "Move machine-specific lines (e.g. conda init) into ~/.localprofile.ps1; conda now loads via the miniconda/ topic."
}

# --- git config ------------------------------------------------------------
$gitConfig = Join-Path $RepoRoot 'git/gitconfig.symlink'
Add-GitInclude -Path (Join-Path $HOME '.gitconfig') -IncludePath '~/.dotfiles/git/gitconfig.symlink' -LinkTarget $gitConfig
Set-Symlink -Path (Join-Path $HOME '.gitignore') -Target (Join-Path $RepoRoot 'git/gitignore.symlink') -Label '.gitignore' | Out-Null

# --- install tooling -------------------------------------------------------
& (Join-Path $PSScriptRoot 'install.ps1')

Write-Host ''
Write-Host 'Done. Open a new PowerShell 7 window to load the profile.'
