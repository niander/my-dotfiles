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
  2. symlinks this repo's profile in as your all-hosts profile.ps1
  3. adds an include of this repo's gitconfig to ~/.gitconfig, and symlinks
     ~/.gitconfig.dotfiles and ~/.gitignore
  4. runs an optional local root's script/configure.ps1
  5. runs install.ps1 (Node.js/npm, pnpm, shell tools and PS modules)
#>

$ErrorActionPreference = 'Stop'

# Windows-only: on Linux/WSL the bash script/bootstrap owns this, and running
# here would double-wire the profile (the ~/.config/powershell profile is
# already symlinked to the repo there).
if (-not $IsWindows) {
    throw 'script/bootstrap.ps1 is for Windows hosts. On Linux/WSL run script/bootstrap (bash).'
}

$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) {
    throw 'git not found; install Git for Windows before running bootstrap.'
}

$scriptRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$RepoRoot = & $git.Source -C $scriptRoot rev-parse --show-toplevel 2>$null
if ($LASTEXITCODE -ne 0 -or -not $RepoRoot) {
    throw "Could not resolve the Git worktree containing '$scriptRoot'."
}
$RepoRoot = [IO.Path]::GetFullPath($RepoRoot.Trim())
$LocalRoot = if ($env:DOTFILES_LOCAL) {
    $env:DOTFILES_LOCAL
}
else {
    Join-Path $HOME '.dotfiles.local'
}
$env:DOTFILES_LOCAL = $LocalRoot

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

function New-LinkState {
    return @{
        AllAction = $null
    }
}

# Resolves a link's target. -AllowMissing accepts one whose target no longer exists.
function Resolve-LinkTarget {
    param(
        [Parameter(Mandatory)] $Item,
        [switch] $AllowMissing
    )

    if (-not $Item.Target) { return $null }

    $target = @($Item.Target)[0]
    $parent = Split-Path -Parent $Item.FullName
    if (-not [System.IO.Path]::IsPathRooted($target)) {
        $target = Join-Path $parent $target
    }

    if ($AllowMissing) { return [IO.Path]::GetFullPath($target, $parent) }
    return (Resolve-Path -LiteralPath $target -ErrorAction SilentlyContinue).Path
}

# Points $Path at $Target, prompting before replacing anything already there.
function Set-Symlink {
    param(
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)][string] $Target,
        [string] $Label = (Split-Path -Leaf $Path),
        [Parameter(Mandatory)][hashtable] $State
    )

    $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
    $existing = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    $backupPath = $null

    if ($existing) {
        $current = Resolve-LinkTarget $existing
        if ($current -eq $resolvedTarget) {
            Write-Host "ok    $Label already links to the repo"
            return $false
        }

        $action = $State.AllAction

        if (-not $action) {
            $action = Read-Host @"
File already exists: $Path ($(Split-Path -Leaf $resolvedTarget)), what do you want to do?
  [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all
"@
            switch -CaseSensitive ($action) {
                'o' { $action = 'overwrite' }
                'O' { $action = 'overwrite'; $State.AllAction = $action }
                'b' { $action = 'backup' }
                'B' { $action = 'backup'; $State.AllAction = $action }
                'S' { $action = 'skip'; $State.AllAction = $action }
                default { $action = 'skip' }
            }
        }

        switch ($action) {
            'overwrite' {
                Remove-Item -LiteralPath $Path -Recurse -Force
                Write-Host "rm    $Label"
            }
            'backup' {
                $backupPath = Get-BackupPath $Path
                Move-Item -LiteralPath $Path -Destination $backupPath -Force
                Write-Host "backup $Label -> $backupPath"
            }
            'skip' {
                Write-Host "skip  $Label"
                return $false
            }
        }
    }

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Path -Target $resolvedTarget | Out-Null
    }
    catch {
        if ($backupPath -and -not (Test-Path -LiteralPath $Path) -and (Test-Path -LiteralPath $backupPath)) {
            Move-Item -LiteralPath $backupPath -Destination $Path -Force
            Write-Warning "Restored $Label after the symbolic link could not be created."
        }
        Write-Warning 'Creating a symbolic link may require Developer Mode (Settings > System > For developers) or an elevated PowerShell.'
        throw
    }
    Write-Host "link  $Label -> $resolvedTarget"
    return ($null -ne $backupPath)
}

# Prepends the baseline to $Path so machine settings below it win. $Path is
# kept a regular file because writes follow a symlink into the checkout.
function Add-GitInclude {
    param(
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)][string] $IncludePath,
        [Parameter(Mandatory)][string] $LegacyIncludePath,
        [Parameter(Mandatory)][string] $BaselineDir
    )

    $label = Split-Path -Leaf $Path
    $existing = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue

    if ($existing -and $existing.LinkType) {
        # AllowMissing: after a pull the old baseline is gone and the link dangles.
        $target = Resolve-LinkTarget $existing -AllowMissing
        if ((Split-Path -Parent $target) -ne $BaselineDir) {
            throw "$label links to '$target', not a config in $BaselineDir. Remove it or migrate its settings, then re-run."
        }
        Remove-Item -LiteralPath $Path -Force
        Write-Host "rm    $label symlink into the checkout"
        $existing = $null
    }

    if ($existing) {
        # Refuse a file git cannot parse rather than editing it.
        & git config --file $Path --list *> $null
        if ($LASTEXITCODE -ne 0) {
            throw "git cannot parse $label. Fix it, then re-run."
        }

        if (Test-GitIncludeFirst -Path $Path -IncludePath $IncludePath) {
            Write-Host "ok    $label already includes the baseline"
            return
        }

        $entries = @(& git config --file $Path --get-all include.path 2>$null)
        if ($entries -ccontains $IncludePath) {
            throw "$label includes $IncludePath below the top, where the baseline overrides machine settings. Move it to the first line and re-run."
        }
        if ($entries -ccontains $LegacyIncludePath) {
            throw "$label includes $LegacyIncludePath, replaced by $IncludePath. Drop that include and re-run."
        }
    }

    $body = if ($existing) { Get-Content -LiteralPath $Path -Raw } else { '' }
    $eol = if ($body -match "`r`n") { "`r`n" } else { "`n" }
    Set-Content -LiteralPath $Path -NoNewline -Encoding utf8NoBOM `
        -Value "[include]$eol`tpath = $IncludePath$eol$body"
    Write-Host "add   $label -> include $IncludePath"
}

# True when $Path opens with an [include] of $IncludePath. Tolerates CRLF and
# spacing: the file may have been written on another host.
function Test-GitIncludeFirst {
    param(
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)][string] $IncludePath
    )

    $lines = @(Get-Content -LiteralPath $Path -TotalCount 2)
    if ($lines.Count -lt 2) { return $false }

    $escaped = [regex]::Escape($IncludePath)
    # Git matches section and key names case-insensitively, values exactly.
    return ($lines[0] -match '^[ \t]*\[include\][ \t]*$') -and
           ($lines[1] -match '^[ \t]*path[ \t]*=') -and
           ($lines[1] -cmatch "=[ \t]*$escaped[ \t]*$")
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
$linkState = New-LinkState
$profileTarget = Join-Path $RepoRoot 'powershell/config/powershell/profile.ps1.symlink'
$profileBackedUp = Set-Symlink -Path $PROFILE.CurrentUserAllHosts -Target $profileTarget `
    -Label 'profile.ps1' -State $linkState
if ($profileBackedUp) {
    Write-Warning "Move machine-specific lines (e.g. conda init) into ~/.localprofile.ps1; conda now loads via the miniconda/ topic."
}

# --- git config ------------------------------------------------------------
$baseline = Join-Path $RepoRoot 'git/gitconfig.dotfiles.symlink'
Set-Symlink -Path (Join-Path $HOME '.gitconfig.dotfiles') -Target $baseline `
    -Label '.gitconfig.dotfiles' -State $linkState | Out-Null
Set-Symlink -Path (Join-Path $HOME '.gitignore') `
    -Target (Join-Path $RepoRoot 'git/gitignore.symlink') `
    -Label '.gitignore' -State $linkState | Out-Null
Add-GitInclude -Path (Join-Path $HOME '.gitconfig') `
    -IncludePath '~/.gitconfig.dotfiles' `
    -LegacyIncludePath '~/.dotfiles/git/gitconfig.symlink' `
    -BaselineDir (Split-Path -Parent $baseline)

# --- optional local configuration ------------------------------------------
$localConfigurator = Join-Path $LocalRoot 'script/configure.ps1'
if (Test-Path -LiteralPath $localConfigurator -PathType Leaf) {
    Write-Host '== local/configure'
    & $localConfigurator
}

# --- install tooling -------------------------------------------------------
& (Join-Path $PSScriptRoot 'install.ps1')

Write-Host ''
Write-Host 'Done. Open a new PowerShell 7 window to load the profile.'
