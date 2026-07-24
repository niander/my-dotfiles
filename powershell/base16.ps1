#Requires -Version 7.0

# --- base16-shell for PowerShell ---------------------------------------------------
# Runtime port of tinted-shell / base16-shell (github.com/tinted-theming/tinted-shell).

# Locate the checkout from this file's own location (powershell/ -> repo root).
# Falls back to the ~/.dotfiles symlink only if $PSScriptRoot is unavailable.
$script:Base16DotfilesRoot = if ($PSScriptRoot) { Split-Path -Parent $PSScriptRoot } else { Join-Path $HOME '.dotfiles' }
$script:Base16Root        = Join-Path $script:Base16DotfilesRoot 'base16-shell/.base16-shell'
$script:Base16ScriptsDir  = Join-Path $script:Base16Root 'scripts'
$script:Base16EnabledFile = Join-Path $script:Base16DotfilesRoot 'base16-shell/.base16_enabled'
$script:Base16_256File    = Join-Path $script:Base16DotfilesRoot 'base16-shell/.base16_256colorspace'
$script:Base16ThemeLink   = Join-Path $HOME '.base16_theme'

function Get-Base16Theme {
    <#.SYNOPSIS List available base16 theme names.#>
    if (-not (Test-Path -LiteralPath $script:Base16ScriptsDir)) { return @() }
    Get-ChildItem -LiteralPath $script:Base16ScriptsDir -Filter 'base16-*.sh' |
        ForEach-Object { $_.BaseName -replace '^base16-', '' } | Sort-Object
}

function script:Invoke-Base16File {
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Error "base16: theme file not found: $Path"
        return
    }

    # Parse the base16-*.sh definition. Values are literal "rr/gg/bb", but the
    # bright slots are references (e.g. color09="$color01"), resolved against the
    # slots already seen. The reference may be quoted or not across script versions.
    $vars  = @{}
    $theme = $null
    foreach ($line in Get-Content -LiteralPath $Path) {
        if ($line -match '^\s*export\s+BASE16_THEME=(.+?)\s*$') {
            $theme = $Matches[1].Trim('"'); continue
        }
        if ($line -match '^\s*(color\w+)="([0-9a-fA-F]{2}/[0-9a-fA-F]{2}/[0-9a-fA-F]{2})"') {
            $vars[$Matches[1]] = $Matches[2]; continue
        }
        if ($line -match '^\s*(color\w+)="?\$(\w+)"?') {
            $vars[$Matches[1]] = $vars[$Matches[2]]; continue
        }
    }

    $esc = [char]27
    if ($env:TMUX) {
        # tmux swallows OSC palette sequences unless wrapped in a DCS passthrough
        # with inner ESCs doubled (needs `set -g allow-passthrough on`).
        $pre = "${esc}Ptmux;${esc}${esc}]"
        $suf = "${esc}${esc}\${esc}\"
    }
    else {
        $pre = "${esc}]"
        $suf = "${esc}\"
    }

    $out = [System.Text.StringBuilder]::new()

    # Standard 16 palette slots.
    for ($i = 0; $i -le 15; $i++) {
        $key = 'color{0:D2}' -f $i
        if ($vars.ContainsKey($key) -and $vars[$key]) {
            [void]$out.Append("$pre" + "4;$i;rgb:$($vars[$key])" + "$suf")
        }
    }
    # Slots 16-21: theme values when the 256 toggle is on, else xterm's default
    # cube so slot 16 stays black (base16 would remap it to orange).
    $set256 = (Test-Path -LiteralPath $script:Base16_256File) -or [bool]$env:BASE16_SHELL_SET_256COLORSPACE
    $xtermCube = @{ 16 = '00/00/00'; 17 = '00/00/5f'; 18 = '00/00/87'; 19 = '00/00/af'; 20 = '00/00/d7'; 21 = '00/00/ff' }
    for ($i = 16; $i -le 21; $i++) {
        $key = 'color{0:D2}' -f $i
        $val = if ($set256) { $vars[$key] } else { $xtermCube[$i] }
        if ($val) { [void]$out.Append("$pre" + "4;$i;rgb:$val" + "$suf") }
    }
    # foreground / background / cursor (cursor = reverse video)
    if ($vars['color_foreground']) {
        [void]$out.Append("$pre" + "10;rgb:$($vars['color_foreground'])" + "$suf")
    }
    if ($env:BASE16_SHELL_SET_BACKGROUND -ne 'false' -and $vars['color_background']) {
        [void]$out.Append("$pre" + "11;rgb:$($vars['color_background'])" + "$suf")
    }
    [void]$out.Append("$pre" + "12;7" + "$suf")

    [Console]::Write($out.ToString())
    if ($theme) { $env:BASE16_THEME = $theme }
}

function Set-Base16Theme {
    <#
    .SYNOPSIS Apply a base16 theme to the current terminal.
    .EXAMPLE Set-Base16Theme eighties
    .EXAMPLE base16 gruvbox-dark-hard
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete)
            Get-Base16Theme | Where-Object { $_ -like "$wordToComplete*" }
        })]
        [string]$Name
    )

    if (-not $Name) {
        Write-Host 'usage: Set-Base16Theme <name>   (tab-completes)'
        Write-Host "current: $($env:BASE16_THEME)"
        return
    }

    $path = Join-Path $script:Base16ScriptsDir "base16-$Name.sh"
    if (-not (Test-Path -LiteralPath $path)) {
        Write-Error "base16: unknown theme '$Name'. Run Get-Base16Theme to list themes."
        return
    }
    script:Invoke-Base16File -Path $path

    # Persist the choice so new shells re-apply it on load: copy the theme
    # definition to the pointer the loader reads, and set the enable flag.
    Copy-Item -LiteralPath $path -Destination $script:Base16ThemeLink -Force
    if (-not (Test-Path -LiteralPath $script:Base16EnabledFile)) {
        New-Item -ItemType File -Path $script:Base16EnabledFile -Force | Out-Null
    }
}

Set-Alias base16 Set-Base16Theme

function script:Test-Base16Capable {
    if ($env:TERM_PROGRAM -and $env:TERM_PROGRAM -ne 'tmux') { return $false }
    if ($env:WT_SESSION)          { return $true }   # Windows Terminal
    if ($env:ConEmuANSI -eq 'ON') { return $true }   # ConEmu / Cmder
    if ($IsLinux -or $IsMacOS) {                      # real *nix terminal
        return [bool]($env:TERM -and $env:TERM -ne 'dumb')
    }
    return $false   # legacy Windows conhost
}

# Auto-apply on load when enabled and the terminal is capable.
if ((Test-Path -LiteralPath $script:Base16EnabledFile) -and (script:Test-Base16Capable)) {
    if (Test-Path -LiteralPath $script:Base16ThemeLink) {
        script:Invoke-Base16File -Path $script:Base16ThemeLink
    }
    else {
        Set-Base16Theme -Name eighties
    }
}
