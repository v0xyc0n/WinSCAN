Function CheckExtendedSecurityUpdates {
    Write-Debug "### Checking Windows Version..."
    
    $vulnerable = $false
    $osVersion = (Get-CimInstance Win32_OperatingSystem).Caption

    if ( $osVersion -eq "Windows Server 2012" ) {
        $vulnerable = $true
        $supportExtension = $(cscript.exe "C:\Windows\system32\slmgr.vbs" /dlv)

        if ( ( $supportExtension -contains "Year3" ) -and ( Get-Date -lt [datetime]"2026-10-13" ) ) {
            $vulnerable = $false
            Write-Debug "$osVersion with Extended Security Update Year 3 detected - still in support until 2026-10-13"
        }
        elseif ( ( $supportExtension -contains "Year2" ) -and ( Get-Date -lt [datetime]"2025-10-14" ) ) {
            $vulnerable = $false
            Write-Debug "$osVersion with Extended Security Update Year 2 detected - still in support until 2025-10-14"
        }
        else {
            Write-Host -ForegroundColor Red "EOL $osVersion without sufficiently extended support detected!"
        }
    }
    else {
        Write-Debug "$osVersion detected; currently, only Windows Server 2012 extended support is checked."
        Write-Debug "To find out if your version is still supported, use https://learn.microsoft.com/de-de/lifecycle/products"
    }

    if ( $vulnerable ) {
        Write-Host -ForegroundColor DarkCyan "Verify via:"
        Write-Host -ForegroundColor DarkCyan "`$cscript.exe C:\Windows\system32\slmgr.vbs /dlv"
        Write-Host -ForegroundColor DarkCyan "And then check against https://learn.microsoft.com/de-de/lifecycle/products/windows-server-2012-r2"
    }
    else {
        Write-Debug "All Good"
    }

}