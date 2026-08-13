#Requires -Version 7.0

# Installs the GitHub CLI (gh) via winget on Windows and regenerates its
# PowerShell completion.

$ErrorActionPreference = 'Continue'

. (Join-Path $PSScriptRoot '..' 'powershell' 'lib' 'winget.ps1')

if ($IsWindows) {
    Install-WingetPackage -Id 'GitHub.cli' -Command 'gh'
}
elseif (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Warning "gh not found; on Linux/WSL run script/install (bash) to install it"
}

$gh = Get-Command gh -ErrorAction SilentlyContinue
if (-not $gh) {
    # winget updates the machine PATH, not this process's, so a just-installed
    # gh stays invisible until a new shell.
    Write-Warning "gh not on PATH; re-run script/install.ps1 in a new shell to generate its completion"
    return
}

# The pwsh profile dot-sources this fragment. Native commands don't raise
# terminating errors, so check the exit code instead of relying on catch, and
# only overwrite once there is real output.
$dest = Join-Path $PSScriptRoot '_gh.ps1'
$completion = & $gh.Source completion -s powershell 2>$null
if ($LASTEXITCODE -eq 0 -and $completion) {
    $completion | Set-Content -LiteralPath $dest -Encoding utf8
    Write-Host "ok       gh pwsh completion"
}
else {
    Write-Warning "gh pwsh completion failed"
}

# The github.com credential helper only answers once an account is stored.
& $gh.Source auth status *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Warning "gh: run 'gh auth login' to enable the github.com credential helper"
}
