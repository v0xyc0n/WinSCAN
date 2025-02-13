Function CheckCoinstallerDeactivated {
    Write-Debug "### Checking for Coinstaller deactivation (see Razer PrivEsc)"

    $KeyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer'
    $ValueName = 'DisableCoInstallers'

    try{  
        $co_installer_enabled = Get-ItemProperty -Path $KeyPath -Name $valueName -ErrorAction Stop | Select-Object -ExpandProperty DisableCoInstallers
        if ( $co_installer_enabled -ne 1 ) {
            Write-Host -ForegroundColor Red "Coinstaller not Disabled!"
            Write-Host -ForegroundColor DarkCyan "Verify via:"
            Write-Host -ForegroundColor DarkCyan "Get-ItemProperty -Path '$KeyPath' -Name $valueName"
        }
        else {
            Write-Debug "Co-Installer Disabled. All good."
        }
    }  
    catch {  
        Write-Host -ForegroundColor Red "Coinstaller not Disabled!"
    }
}