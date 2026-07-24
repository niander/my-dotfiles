# Initialize conda for PowerShell: discover conda from PATH or a conventional
# install root, then set up its shell integration. Prefer dot-sourcing conda's
# generated hook script, which is fast; fall back to `conda shell.powershell
# hook` (which spawns a Python process every shell start) only when that script
# is absent. oh-my-posh loads after this and owns the prompt, so the active env
# shows once (via the theme) instead of being prepended twice.

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
    # The conda executable sits two levels below the install root (e.g.
    # <root>/Scripts/conda.exe, <root>/condabin/conda.bat, <root>/bin/conda).
    $condaRoot = Split-Path -Parent (Split-Path -Parent $condaExe)
    $condaHook = Join-Path $condaRoot 'shell/condabin/conda-hook.ps1'
    if (Test-Path -LiteralPath $condaHook) {
        . $condaHook
    }
    else {
        (& $condaExe 'shell.powershell' 'hook') | Out-String | Invoke-Expression
    }
}

Remove-Variable condaExe, roots, root, exe, condaRoot, condaHook -ErrorAction SilentlyContinue
