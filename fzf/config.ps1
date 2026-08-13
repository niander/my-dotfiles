#Requires -Version 7.0

# Ctrl+T picks files; Ctrl+R searches command history.
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    if (Import-Module PSFzf -PassThru -ErrorAction SilentlyContinue) {
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    }
}
