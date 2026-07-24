#Requires -Version 7.0
# Prepend user-local bins to PATH.

$userBin = Join-Path $HOME '.local/bin'
if ((Test-Path $userBin) -and (($env:PATH -split [IO.Path]::PathSeparator) -notcontains $userBin)) {
    $env:PATH = "$userBin$([IO.Path]::PathSeparator)$env:PATH"
}
Remove-Variable userBin -ErrorAction SilentlyContinue
