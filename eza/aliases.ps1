# Define eza-backed listing helpers only when eza is available.
# These use eza-native flags; legacy ls options such as -F, -t, and -s # are unsupported.
# Leave the built-in `ls` alias untouched to preserve its native output.
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function l { eza -la @args }
    function la { eza -la @args }
    function ll { eza -l @args }
    function lt { eza -l --sort=modified --reverse @args } # newest first
    function lr { eza -l -R @args }
    function lsr { eza -la -R @args }
    function lsn { eza -1 @args }
    function ltree { eza --tree @args } # --level=N to limit depth
}
