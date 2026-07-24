# Define eza-backed listing helpers only when eza is available.
# These use eza-native flags; legacy ls options such as -F, -t, and -s # are unsupported.
# Leave the built-in `ls` alias untouched to preserve its native output.
if (Get-Command eza -ErrorAction SilentlyContinue) {
    $env:EZA_COLORS = 'da=0' # date in default color
    function l { eza -la --smart-group @args }
    function la { eza -la --smart-group @args }
    function ll { eza -l --smart-group @args }
    function lt { eza -l --smart-group --sort=modified --reverse @args } # newest first
    function lr { eza -l --smart-group -R @args }
    function lsr { eza -la --smart-group -R @args }
    function lsn { eza -1 @args }
    function ltree { eza --tree @args } # --level=N to limit depth
}
