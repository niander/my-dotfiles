#Requires -Version 7.0
# Set up conda for PowerShell.
#
# First, look for conda in PATH. If it is not found, check common install
# locations. `conda shell.powershell hook` emits the environment variables that
# conda's own hook script depends on, so the script cannot be sourced directly.
#
# oh-my-posh loads later and displays the active environment in the prompt.

$condaExe = (Get-Command conda -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1).Source

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
