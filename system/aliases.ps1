#Requires -Version 7.0

# Listing aliases used when eza is not installed; eza's own aliases replace these when it is.
if (-not (Get-Command eza -ErrorAction SilentlyContinue)) {
    # Differences from traditional ls:
    #   - Get-ChildItem already uses a detailed, tabular view, so no -l alias is needed.
    #   - l and la are equivalent: PowerShell has no . or .. entries, so there is no
    #     distinction between ls -A and ls -a. Here, -Force simply includes hidden items.
    function l { Get-ChildItem -Force @args }
    function la { Get-ChildItem -Force @args }
    function ll { Get-ChildItem @args }
    function lt { Get-ChildItem @args | Sort-Object LastWriteTime -Descending }  # newest first
    function lr { Get-ChildItem -Recurse @args }
}

# Color Get-ChildItem output (PowerShell 7.2+).
# This is not conditional on eza: bare `ls` remains native even when eza is
# installed. ANSI color names, rather than fixed RGB values, let listings
# follow the active base16 theme.
if ($PSStyle) {
    $fi = $PSStyle.FileInfo
    $fg = $PSStyle.Foreground
    $b = $PSStyle.Bold

    $fi.Directory    = $b + $fg.Blue
    $fi.SymbolicLink = $b + $fg.Cyan
    $fi.Executable   = $b + $fg.Green

    $archive = $b + $fg.Red
    foreach ($ext in '.tar', '.tgz', '.taz', '.zip', '.z', '.gz', '.bz2', '.tbz',
        '.xz', '.zst', '.7z', '.rar', '.lz', '.lzo', '.lz4', '.deb', '.rpm', '.jar', '.cab') {
        $fi.Extension[$ext] = $archive
    }

    Remove-Variable fi, fg, b, archive, ext -ErrorAction SilentlyContinue
}
