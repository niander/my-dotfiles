#Requires -Version 7.0

# Installs uv with Astral's standalone installer on Windows.
# Linux/WSL use install.sh.

$ErrorActionPreference = 'Stop'

if (Get-Command uv -ErrorAction SilentlyContinue) {
    Write-Host 'ok       uv already installed'
    return
}

if (-not $IsWindows) {
    Write-Warning 'uv not found; on Linux/WSL run script/install (bash) to install it'
    return
}

$installDir = Join-Path $HOME '.local/bin'
$installer = Join-Path ([IO.Path]::GetTempPath()) "uv-install-$([guid]::NewGuid()).ps1"
$previousInstallDir = $env:UV_INSTALL_DIR
$previousNoModifyPath = $env:UV_NO_MODIFY_PATH

try {
    Invoke-RestMethod 'https://astral.sh/uv/install.ps1' -OutFile $installer
    $env:UV_INSTALL_DIR = $installDir
    $env:UV_NO_MODIFY_PATH = '1'
    & $installer
}
finally {
    Remove-Item -LiteralPath $installer -Force -ErrorAction SilentlyContinue

    if ($null -eq $previousInstallDir) {
        Remove-Item Env:UV_INSTALL_DIR -ErrorAction SilentlyContinue
    }
    else {
        $env:UV_INSTALL_DIR = $previousInstallDir
    }

    if ($null -eq $previousNoModifyPath) {
        Remove-Item Env:UV_NO_MODIFY_PATH -ErrorAction SilentlyContinue
    }
    else {
        $env:UV_NO_MODIFY_PATH = $previousNoModifyPath
    }
}

Write-Host 'ok       installed uv'
