#Requires -Version 7.0

# Installs the PowerShell prompt tooling.
# Cross-platform, idempotent.
# Run by script/install.ps1.

$ErrorActionPreference = 'Continue'

function Install-WingetPackage {
    param([string]$Id, [string]$Command)

    if (Get-Command $Command -ErrorAction SilentlyContinue) {
        Write-Host "ok       $Command already installed"
        return
    }
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Warning "winget not found; install $Id manually"
        return
    }
    Write-Host "install  $Id (winget) ..."
    winget install --id $Id --source winget --accept-source-agreements --accept-package-agreements
}

# oh-my-posh: winget on Windows, the official install script elsewhere.
if ($IsWindows) {
    Install-WingetPackage -Id 'JanDeDobbeleer.OhMyPosh' -Command 'oh-my-posh'
}
elseif (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    Write-Host "ok       oh-my-posh already installed"
}
elseif (Get-Command curl -ErrorAction SilentlyContinue) {
    Write-Host "install  oh-my-posh (script) ..."
    New-Item -ItemType Directory -Force -Path "$HOME/.local/bin" | Out-Null
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"
}
else {
    Write-Warning "curl not found; install oh-my-posh manually: https://ohmyposh.dev"
}

# fzf: winget on Windows. On other platforms install it with the system package
# manager (it's usually already present); PSFzf below no-ops without it.
if ($IsWindows) {
    Install-WingetPackage -Id 'junegunn.fzf' -Command 'fzf'
}

foreach ($m in 'posh-git', 'git-aliases', 'PSFzf', 'CompletionPredictor') {
    if (Get-Module -ListAvailable -Name $m) {
        Write-Host "ok       module $m already installed"
        continue
    }
    Write-Host "install  module $m ..."
    try {
        Install-PSResource -Name $m -Repository PSGallery -TrustRepository -Scope CurrentUser -ErrorAction Stop
    }
    catch {
        Write-Warning "failed to install ${m}: $($_.Exception.Message)"
    }
}
