#Requires -Version 7.0

# Ctrl+T picks files; Ctrl+R searches command history.
if ((Get-Module PSReadLine) -and (Get-Command fzf -ErrorAction SilentlyContinue)) {
    function Initialize-PSFzf {
        Import-Module PSFzf -Global -ErrorAction Stop
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    }

    Set-PSReadLineKeyHandler -Chord 'Ctrl+t' -BriefDescription 'PSFzfProvider' -LongDescription 'Load PSFzf and select files' -ScriptBlock {
        try {
            Initialize-PSFzf
            Invoke-FzfPsReadlineHandlerProvider
        }
        catch {
            $Host.UI.WriteErrorLine("PSFzf: $($_.Exception.Message)")
        }
    }

    Set-PSReadLineKeyHandler -Chord 'Ctrl+r' -BriefDescription 'PSFzfHistory' -LongDescription 'Load PSFzf and search history' -ScriptBlock {
        try {
            Initialize-PSFzf
            Invoke-FzfPsReadlineHandlerHistory
        }
        catch {
            $Host.UI.WriteErrorLine("PSFzf: $($_.Exception.Message)")
        }
    }
}
