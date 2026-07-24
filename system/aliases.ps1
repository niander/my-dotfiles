# Long directory listings. Get-ChildItem already renders a long-format table;
# -Force adds hidden and system entries.
function l  { Get-ChildItem -Force @args }
function la { Get-ChildItem -Force @args }
function ll { Get-ChildItem @args }

# Built-in file coloring (PowerShell 7.2+): bold blue directories, bold cyan
# symlinks, bold green executables, bold red archives; everything else stays
# uncolored. ANSI color names emit the standard 16 colors, which base16
# reprograms, so these track the active theme.
if ($PSStyle) {
    $fi = $PSStyle.FileInfo
    $fg = $PSStyle.Foreground
    $b  = $PSStyle.Bold

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
