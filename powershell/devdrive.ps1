#Requires -Version 7.0

if ($IsWindows) {
    & {
        $volume = Get-Volume -DriveLetter D -ErrorAction SilentlyContinue
        if (-not $volume -or $volume.FileSystemType -ne 'ReFS') { return }

        $existingDrive = Get-PSDrive -Name devfs -ErrorAction SilentlyContinue
        if ($existingDrive) {
            if ($existingDrive.Provider.Name -ne 'FileSystem' -or $existingDrive.Root -ne 'D:\') {
                Write-Warning "devfs: already maps to '$($existingDrive.Root)'; leaving it unchanged"
            }
            return
        }

        New-PSDrive -Name devfs -PSProvider FileSystem -Root 'D:\' -Scope Global | Out-Null
    }
}
