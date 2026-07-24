#Requires -Version 7.0
# Set up conda for PowerShell.
#
# First, look for conda in PATH. If it is not found, check common install
# locations. Use conda's hook script when available because it starts faster.
# Otherwise, run `conda shell.powershell hook` as a fallback.
#
# oh-my-posh loads later and displays the active environment in the prompt.

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
