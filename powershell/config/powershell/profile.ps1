# PowerShell profile -- niander/my-dotfiles
# ---------------------------------------------------------------------------
# Canonical profile. script/bootstrap links it to the Linux/WSL all-hosts
# profile. On Windows, script/bootstrap.ps1 adds a source call to the regular
# all-hosts profile, which may live under OneDrive. The host profile
# (Microsoft.PowerShell_profile.ps1) is left alone. See powershell/README.md.

# Prefer the exported root used by the Windows profile source.
$DotfilesRoot = if ($env:DOTFILES -and (Test-Path -LiteralPath $env:DOTFILES -PathType Container)) {
    $env:DOTFILES
}
elseif (Test-Path "$HOME/.dotfiles") {
    "$HOME/.dotfiles"
}
else {
    $null
}
if ($DotfilesRoot) { $env:DOTFILES = $DotfilesRoot }
$LocalDotfilesRoot = if ($env:DOTFILES_LOCAL) {
    $env:DOTFILES_LOCAL
}
else {
    Join-Path $HOME '.dotfiles.local'
}
$env:DOTFILES_LOCAL = $LocalDotfilesRoot
$DotfilesRoots = @($DotfilesRoot, $LocalDotfilesRoot) |
    Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Container) }
$PSTopic = if ($DotfilesRoot) { Join-Path $DotfilesRoot 'powershell' } else { $PSScriptRoot }

# Invoke-Command -NoNewScope lets the alias reload into the interactive scope.
if (-not $PSDefaultParameterValues) {
    $global:PSDefaultParameterValues = @{}
}
$PSDefaultParameterValues['reload!:ScriptBlock'] = { {
    foreach ($reloadProfile in $PROFILE.CurrentUserAllHosts, $PROFILE.CurrentUserCurrentHost) {
        if (Test-Path $reloadProfile) { . $reloadProfile }
    }
    Remove-Variable reloadProfile -ErrorAction SilentlyContinue
} }
$PSDefaultParameterValues['reload!:NoNewScope'] = $true
Set-Alias reload! Invoke-Command

# --- Topical PATH setup ----------------------------------------------------
# Each topic's path.ps1 runs first, so later fragments and prompt tools (fzf,
# oh-my-posh) see the finished PATH. A failing one is warned about, not fatal.
& {
    $declaredPaths = [Collections.Generic.List[string]]::new()

    function Add-DotfilesPath {
        param([Parameter(Mandatory)][string] $Path)

        $declaredPaths.Add($Path)
    }

    function ConvertTo-DotfilesPath {
        param([Parameter(Mandatory)][string] $Path)

        try {
            $expandedPath = [Environment]::ExpandEnvironmentVariables($Path)
            [IO.Path]::TrimEndingDirectorySeparator([IO.Path]::GetFullPath($expandedPath))
        }
        catch {
            $null
        }
    }

    foreach ($root in $DotfilesRoots) {
        $pathPattern = Join-Path (Join-Path $root '*') 'path.ps1'
        foreach ($pathFragment in @(Get-ChildItem -Path $pathPattern -File | Sort-Object FullName)) {
            try { . $pathFragment.FullName }
            catch { Write-Warning "profile path fragment $($pathFragment.Directory.Name): $($_.Exception.Message)" }
        }
    }

    $pathComparer = if ($IsWindows) {
        [StringComparer]::OrdinalIgnoreCase
    }
    else {
        [StringComparer]::Ordinal
    }
    $seenPaths = [Collections.Generic.HashSet[string]]::new($pathComparer)
    $preferredPaths = [Collections.Generic.List[string]]::new()

    for ($i = $declaredPaths.Count - 1; $i -ge 0; $i--) {
        $candidate = ConvertTo-DotfilesPath $declaredPaths[$i]
        if ($candidate -and [IO.Directory]::Exists($candidate) -and $seenPaths.Add($candidate)) {
            $preferredPaths.Add($candidate)
        }
    }

    $remainingPaths = foreach ($entry in $env:PATH -split [IO.Path]::PathSeparator) {
        if (-not $entry) { continue }
        $normalizedEntry = ConvertTo-DotfilesPath $entry
        if (-not $normalizedEntry -or -not $seenPaths.Contains($normalizedEntry)) {
            $entry
        }
    }

    $env:PATH = @($preferredPaths; $remainingPaths) -join [IO.Path]::PathSeparator
}

# --- Prediction plugin -----------------------------------------------------
# Import-Module no-ops when the optional module is absent.
Import-Module CompletionPredictor -ErrorAction SilentlyContinue

# --- PSReadLine ------------------------------------------------------------
# Import explicitly so hosts cannot defer PSReadLine until after profile processing.
Import-Module PSReadLine -ErrorAction SilentlyContinue

if (Get-Module PSReadLine) {
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineKeyHandler -Key Tab             -Function MenuComplete
    Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineKeyHandler -Key UpArrow         -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow       -Function HistorySearchForward

    # Syntax colors for the input buffer. ANSI color names, rather than fixed RGB
    # values, let the buffer follow the active base16 theme. $PSStyle needs 7.2+.
    if ($PSStyle) {
        $fg = $PSStyle.Foreground

        Set-PSReadLineOption -Colors @{
            Command   = $fg.Green
            Keyword   = $fg.Yellow
            String    = $fg.Yellow
            Parameter = $fg.Cyan
            Number    = $fg.Magenta
            Comment   = $fg.BrightBlack
            Operator  = $fg.White
            Variable  = $fg.BrightCyan
            Type      = $fg.Blue
            Member    = $fg.White
            Error     = $PSStyle.Bold + $fg.Red
            Emphasis  = $fg.BrightYellow
        }

        Remove-Variable fg -ErrorAction SilentlyContinue
    }

    # Predictions need PSReadLine >= 2.2; degrade gracefully on older builds
    # (e.g. the 2.0 that ships with Windows PowerShell 5.1). Inline is the
    # everyday view; F2 toggles to the ListView dropdown.
    try {
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
        Set-PSReadLineOption -PredictionViewStyle InlineView
        Set-PSReadLineKeyHandler -Key F2 -Function SwitchPredictionView
    }
    catch {
        try { Set-PSReadLineOption -PredictionSource History } catch { }
    }
}

# --- Topical fragments -----------------------------------------------------
# Dot-source each topic's *.ps1. Loaded before oh-my-posh so its prompt wins
# over anything a fragment sets (e.g. conda). path.ps1 (ran earlier), install.ps1
# (installer), and the script/ dir are not fragments, so they are skipped. A
# failing fragment is warned about, not fatal, so one bad file can't leave you
# with no prompt.
foreach ($root in $DotfilesRoots) {
    foreach ($topic in Get-ChildItem -LiteralPath $root -Directory) {
        if ($topic.Name -eq 'script') { continue }
        foreach ($fragment in @(Get-ChildItem -LiteralPath $topic.FullName -File | Where-Object { $_.Extension -eq '.ps1' -and $_.Name -notin 'install.ps1', 'path.ps1' })) {
            try { . $fragment.FullName }
            catch { Write-Warning "profile fragment $($fragment.Name): $($_.Exception.Message)" }
        }
    }
}

# --- Prompt: oh-my-posh ----------------------------------------------------
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    $ompTheme = Join-Path $PSTopic 'niander.omp.json'
    if (Test-Path $ompTheme) {
        oh-my-posh init pwsh --config $ompTheme | Invoke-Expression
    }
    else {
        oh-my-posh init pwsh | Invoke-Expression
    }
}

# --- Per-machine overrides -------------------------------------------------
$localProfile = Join-Path $HOME '.localprofile.ps1'
if (Test-Path $localProfile) { . $localProfile }

# This profile runs in the global scope, so its top-level variables would
# linger in the session; drop the startup scratch ones.
Remove-Variable DotfilesRoot, LocalDotfilesRoot, DotfilesRoots, PSTopic, ompTheme,
    localProfile, root, topic, pathPattern, pathFragment, fragment -ErrorAction SilentlyContinue
