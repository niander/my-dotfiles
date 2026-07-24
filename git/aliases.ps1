# The git-aliases module removes several built-in aliases (gc, gcb, gcm, gcs,
# gl, gm, gp, gpv) to define its own git functions in their place. Reassert the
# built-ins here, and keep the most useful displaced git shortcuts under names
# that do not collide. The module auto-loads lazily on first use, so import it
# up front to make these reversions deterministic.
Import-Module git-aliases -ErrorAction SilentlyContinue

# Preserve a few git shortcuts under non-colliding names before their originals
# revert to built-ins below. Copying the module's own function keeps whatever
# behavior it defines (e.g. main-branch detection) rather than reimplementing it.
$gitAliasRename = [ordered]@{
    gl  = 'gpull'    # git pull
    gcm = 'gcmain'   # git checkout <main branch>
    gp  = 'gpush'    # git push
}
foreach ($from in $gitAliasRename.Keys) {
    $body = (Get-Item "Function:$from" -ErrorAction SilentlyContinue).ScriptBlock
    if ($body) { Set-Item "Function:global:$($gitAliasRename[$from])" -Value $body }
}

# Restore the built-in aliases the module stripped.
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
