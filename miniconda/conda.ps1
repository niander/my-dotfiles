# Initialize conda for PowerShell: discover conda from PATH or a conventional
# install root, then run its PowerShell hook. oh-my-posh loads after this and
# owns the prompt, so the active env shows once (via the theme) instead of being
# prepended twice.

$condaExe = (Get-Command conda -ErrorAction SilentlyContinue).Source

if (-not $condaExe) {
    $roots = @("$HOME/miniconda3", "$HOME/anaconda3")
    if ($env:LOCALAPPDATA) {
        $roots += "$env:LOCALAPPDATA/miniconda3", "$env:LOCALAPPDATA/anaconda3"
    }
    foreach ($root in $roots) {
        $exe = if ($IsWindows) { Join-Path $root 'Scripts/conda.exe' } else { Join-Path $root 'bin/conda' }
        if (Test-Path -LiteralPath $exe) { $condaExe = $exe; break }
    }
}

if ($condaExe) {
    (& $condaExe 'shell.powershell' 'hook') | Out-String | Invoke-Expression
}

Remove-Variable condaExe, roots, root, exe -ErrorAction SilentlyContinue
