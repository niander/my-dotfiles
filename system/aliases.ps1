# Long directory listings. Get-ChildItem already renders a long-format table;
# -Force adds hidden and system entries.
function l  { Get-ChildItem -Force @args }
function la { Get-ChildItem -Force @args }
function ll { Get-ChildItem @args }
