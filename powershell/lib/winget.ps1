#Requires -Version 7.0

$wingetCommand = Get-Command winget -ErrorAction SilentlyContinue

function Install-WingetPackage {
    param(
        [Parameter(Mandatory)][string] $Id,
        [Parameter(Mandatory)][string] $Command,
        [string] $Name = $Command,
        [string] $Override
    )

    if (Get-Command $Command -ErrorAction SilentlyContinue) {
        Write-Host "ok       $Command already installed"
        return
    }
    if (-not $wingetCommand) {
        Write-Warning "winget not found; install $Name manually"
        return
    }

    $wingetArguments = @(
        'install'
        '--id', $Id
        '--exact'
        '--source', 'winget'
        '--accept-source-agreements'
        '--accept-package-agreements'
        '--disable-interactivity'
    )
    if ($Override) {
        $wingetArguments += '--override', $Override
    }

    Write-Host "install  $Name (winget) ..."
    & $wingetCommand.Source @wingetArguments
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "$Name installation failed"
    }
}
