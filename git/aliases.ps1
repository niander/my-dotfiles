# git-aliases replaces several built-in aliases with git functions.
# Import it first, preserve selected git shortcuts under new names, then
# restore the built-in aliases.
Import-Module git-aliases -DisableNameChecking -ErrorAction SilentlyContinue

# Keep selected git shortcuts before restoring the built-in aliases.
$gitAliasRename = [ordered]@{
    gl  = 'gpull'    # git pull
    gcm = 'gcmain'   # git checkout <main branch>
    gp  = 'gpush'    # git push
}
foreach ($from in $gitAliasRename.Keys) {
    $body = (Get-Item "Function:$from" -ErrorAction SilentlyContinue).ScriptBlock
    if ($body) { Set-Item "Function:global:$($gitAliasRename[$from])" -Value $body }
}

# Restore built-in aliases.
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
foreach ($alias in $gitAliasRestore.Keys) {
    Remove-Item "Function:$alias" -Force -ErrorAction SilentlyContinue
    Set-Alias -Name $alias -Value $gitAliasRestore[$alias] -Scope Global -Force
}

Remove-Variable gitAliasRename, gitAliasRestore, from, alias, body -ErrorAction SilentlyContinue
