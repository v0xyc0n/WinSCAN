Function CheckUserWriteablePath {
    Write-Debug "### Checking PATH for writable locations by user..."
    $vulnerable = $false
    $ErrorActionPreference = 'SilentlyContinue'
    $temp_file = "test_file.tmp"
    $paths = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name Path).Path -split ';'

    try {
        $paths | Out-File -FilePath "output\sytem_PATH.txt" -ErrorAction "SilentlyContinue"
    }
    catch {
        Write-Host $_
    }
    
    foreach ($path in $paths) {
        $path = $path.Trim()

        if (-not [string]::IsNullOrWhiteSpace($path)) {
            $temp_file_path = Join-Path -Path $path -ChildPath $temp_file

            try {
                Add-Content -Path $temp_file_path -Value "Test"

                if (Test-Path $temp_file_path) {
                    Remove-Item $temp_file_path -Force
                    Write-Host -ForegroundColor Red "$path`: WRITABLE!"
                    Write-Host -ForegroundColor DarkCyan "Verify via:"
                    Write-Host -ForegroundColor DarkCyan "(Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name Path).Path -split ';'"
                    Write-Host -ForegroundColor DarkCyan "accesschk.exe /accepteula -d $(& whoami) '$path'"
                    $vulnerable = $true
                }
            }
            catch { } # Do nothing, errors will be suppressed due to $ErrorActionPreference
        }
    }

    if ( -Not $vulnerable ) {
        Write-Debug "All good."
    }
}