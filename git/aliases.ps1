# Preserve selected git shortcuts without replacing PowerShell's built-ins.
$gitAliasRename = [ordered]@{
    gl  = 'gpull'    # git pull
    gcm = 'gcmain'   # git checkout <main branch>
    gp  = 'gpush'    # git push
}
$gitAliasRestore = [ordered]@{
    gc  = 'Get-Content'
    gcb = 'Get-Clipboard'
    gcm = 'Get-Command'
    gcs = 'Get-PSCallStack'
    gl  = 'Get-Location'
    gm  = 'Get-Member'
    gp  = 'Get-ItemProperty'
    gpv = 'Get-ItemPropertyValue'
}

Import-Module git-aliases -DisableNameChecking -ErrorAction SilentlyContinue

# Keep selected git shortcuts before restoring the built-in aliases.
foreach ($from in $gitAliasRename.Keys) {
    $body = (Get-Item "Function:$from" -ErrorAction SilentlyContinue).ScriptBlock
    if ($body) { Set-Item "Function:global:$($gitAliasRename[$from])" -Value $body }
}

# Restore built-in aliases.
foreach ($alias in $gitAliasRestore.Keys) {
    Remove-Item "Function:$alias" -Force -ErrorAction SilentlyContinue
    Set-Alias -Name $alias -Value $gitAliasRestore[$alias] -Scope Global -Force
}

# Load posh-git on the first Git completion request and complete that request.
if (-not (Get-Module posh-git)) {
    Microsoft.PowerShell.Core\Register-ArgumentCompleter -Native -CommandName 'git', 'git.exe', 'tgit', 'gitk', 'gitk.exe' -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)

        try {
            Import-Module posh-git -Global -ErrorAction Stop
            $padLength = $cursorPosition - $commandAst.Extent.StartOffset
            $textToComplete = $commandAst.ToString().PadRight($padLength, ' ').Substring(0, $padLength)
            Expand-GitCommand $textToComplete
        }
        catch {
            $Host.UI.WriteErrorLine("posh-git: $($_.Exception.Message)")
        }
    }
}

Remove-Variable gitAliasRename, gitAliasRestore, from, alias, body -ErrorAction SilentlyContinue
