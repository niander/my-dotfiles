# Prepend user-local bins to PATH. oh-my-posh (and fzf) can install into
# ~/.local/bin, which isn't on PATH unless the launching shell already added it.
$userBin = Join-Path $HOME '.local/bin'
if ((Test-Path $userBin) -and (($env:PATH -split [IO.Path]::PathSeparator) -notcontains $userBin)) {
    $env:PATH = "$userBin$([IO.Path]::PathSeparator)$env:PATH"
}
Remove-Variable userBin -ErrorAction SilentlyContinue
