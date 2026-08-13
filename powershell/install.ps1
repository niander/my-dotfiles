#Requires -Version 7.0

# Installs the PowerShell prompt tooling.
# Cross-platform, idempotent.
# Run by script/install.ps1.

$ErrorActionPreference = 'Continue'

. (Join-Path $PSScriptRoot 'lib' 'winget.ps1')

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
# manager (it's usually already present); the fzf topic no-ops without it.
if ($IsWindows) {
    Install-WingetPackage -Id 'junegunn.fzf' -Command 'fzf'
}

$moduleRoot = if ($IsWindows) {
    Join-Path $HOME 'PowerShell/Modules'
}
else {
    Join-Path $HOME '.local/share/powershell/Modules'
}

if ($IsWindows) {
    $configPath = Join-Path (Split-Path $PROFILE.CurrentUserCurrentHost) 'powershell.config.json'
    $configuredModulePath = '%USERPROFILE%/PowerShell/Modules'
    $config = if (Test-Path -LiteralPath $configPath) {
        try {
            Get-Content -LiteralPath $configPath -Raw -ErrorAction Stop |
                ConvertFrom-Json -AsHashtable -ErrorAction Stop
        }
        catch {
            throw "failed to read ${configPath}: $($_.Exception.Message)"
        }
    }
    else {
        [ordered]@{}
    }

    $modulePathKeys = @($config.Keys | Where-Object {
        [string]::Equals([string]$_, 'PSModulePath', [StringComparison]::OrdinalIgnoreCase)
    })
    if ($modulePathKeys.Count -gt 1) {
        throw 'powershell.config.json defines PSModulePath more than once; refusing to install dotfiles modules'
    }

    if ($modulePathKeys.Count -eq 1) {
        $modulePathKey = $modulePathKeys[0]
        $configuredEntries = [Environment]::ExpandEnvironmentVariables([string]$config[$modulePathKey]) -split [IO.Path]::PathSeparator
        if ($configuredEntries.Count -ne 1) {
            throw "powershell.config.json already defines PSModulePath as '$($config[$modulePathKey])'; refusing to install dotfiles modules"
        }
        $existingModulePath = [IO.Path]::GetFullPath($configuredEntries[0]).TrimEnd('\', '/')
        $expectedModulePath = [IO.Path]::GetFullPath($moduleRoot).TrimEnd('\', '/')
        if ($existingModulePath -ne $expectedModulePath) {
            throw "powershell.config.json already defines PSModulePath as '$($config[$modulePathKey])'; refusing to install dotfiles modules"
        }
    }
    else {
        $config['PSModulePath'] = $configuredModulePath
        $configDir = Split-Path -Parent $configPath
        try {
            if (-not (Test-Path -LiteralPath $configDir)) {
                New-Item -ItemType Directory -Path $configDir -Force -ErrorAction Stop | Out-Null
            }
            $config | ConvertTo-Json -Depth 100 -ErrorAction Stop |
                Set-Content -LiteralPath $configPath -ErrorAction Stop
        }
        catch {
            throw "failed to write ${configPath}: $($_.Exception.Message)"
        }
        Write-Host "config   PSModulePath -> $moduleRoot"
    }
}

if (-not (Test-Path -LiteralPath $moduleRoot)) {
    New-Item -ItemType Directory -Path $moduleRoot -Force | Out-Null
}

$modulePathEntries = $env:PSModulePath -split [IO.Path]::PathSeparator
if ($modulePathEntries -notcontains $moduleRoot) {
    $env:PSModulePath = "$moduleRoot$([IO.Path]::PathSeparator)$env:PSModulePath"
}
$moduleRootPrefix = $moduleRoot.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar

foreach ($m in 'posh-git', 'git-aliases', 'PSFzf', 'CompletionPredictor') {
    $localModule = Get-Module -ListAvailable -Name $m |
        Where-Object { $_.Path.StartsWith($moduleRootPrefix, [StringComparison]::OrdinalIgnoreCase) } |
        Select-Object -First 1
    if ($localModule) {
        Write-Host "ok       module $m already installed"
        continue
    }
    Write-Host "install  module $m ..."
    try {
        Save-PSResource -Name $m -Repository PSGallery -TrustRepository -IncludeXml -Path $moduleRoot -ErrorAction Stop
    }
    catch {
        Write-Warning "failed to install ${m}: $($_.Exception.Message)"
    }
}

Remove-Variable moduleRoot, configPath, configuredModulePath, config, existingModulePath,
    expectedModulePath, modulePathKeys, modulePathKey, configuredEntries, configDir,
    modulePathEntries, moduleRootPrefix, localModule, m -ErrorAction SilentlyContinue
