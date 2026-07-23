# base16-shell for PowerShell
# ---------------------------------------------------------------------------
# Runtime port of tinted-shell / base16-shell (github.com/tinted-theming/tinted-shell).
#
# base16 themes work by emitting OSC escape sequences that reprogram the
# terminal's palette *live* -- they never touch a config file. This is how the
# zsh side (base16-shell/) themes Windows Terminal from WSL. This script gives
# PowerShell the same behavior by re-emitting the very same base16-*.sh theme
# definitions (single source of truth, shared with the zsh side) as OSC 4/10/
# 11/12 sequences.
#
# Applies in terminals that honor those sequences: Windows Terminal, ConEmu/
# Cmder, Windows 11 conhost, and *nix terminals. GUI terminals that manage their
# own colors (VS Code, etc.) and legacy Windows conhost are skipped.
#
# Public commands:
#   Set-Base16Theme <name>   apply a theme now (alias: base16); tab-completes
#   Get-Base16Theme          list available theme names
# On load it auto-applies when the shared enable flag base16-shell/.base16_enabled
# exists and the terminal is capable, following the theme in ~/.base16_theme and
# honoring the shared .base16_256colorspace toggle.

# Locate the checkout from this file's own location (powershell/ -> repo root),
# matching the profile's location-independent resolution. Falls back to the
# ~/.dotfiles symlink only if $PSScriptRoot is somehow unavailable.
$script:DotfilesRoot = if ($PSScriptRoot) { Split-Path -Parent $PSScriptRoot } else { Join-Path $HOME '.dotfiles' }
$script:Base16Root        = Join-Path $script:DotfilesRoot 'base16-shell/.base16-shell'
$script:Base16ScriptsDir  = Join-Path $script:Base16Root 'scripts'
$script:Base16EnabledFile = Join-Path $script:DotfilesRoot 'base16-shell/.base16_enabled'
$script:Base16_256File    = Join-Path $script:DotfilesRoot 'base16-shell/.base16_256colorspace'
$script:Base16ThemeLink   = Join-Path $HOME '.base16_theme'   # maintained by zsh base16-shell

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

    $e = [char]27
    # tmux swallows OSC palette sequences unless they are wrapped in a DCS
    # passthrough with inner ESCs doubled (needs `set -g allow-passthrough on`).
    if ($env:TMUX) {
        $pre = "${e}Ptmux;${e}${e}]"
        $suf = "${e}${e}\${e}\"
    }
    else {
        $pre = "${e}]"
        $suf = "${e}\"
    }

    $out = [System.Text.StringBuilder]::new()

    # Standard 16 palette slots.
    for ($i = 0; $i -le 15; $i++) {
        $key = 'color{0:D2}' -f $i
        if ($vars.ContainsKey($key) -and $vars[$key]) {
            [void]$out.Append("$pre" + "4;$i;rgb:$($vars[$key])" + "$suf")
        }
    }
    # base16 maps slots 16-21 onto the ANSI-256 cube; index 16 becomes base09
    # (orange), which TUIs that treat 16 as "black" render as unreadable. Emit
    # the theme values only when the 256 toggle is on; otherwise restore xterm's
    # default 6x6x6 cube so index 16 stays black.
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
}

Set-Alias base16 Set-Base16Theme

function script:Test-Base16Capable {
    # Skip GUI terminals that manage their own colors (VS Code, etc.); they set
    # TERM_PROGRAM to something other than tmux. Windows Terminal / conhost don't.
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
        script:Invoke-Base16File -Path $script:Base16ThemeLink   # follow zsh's current choice
    }
    else {
        Set-Base16Theme -Name eighties
    }
}
