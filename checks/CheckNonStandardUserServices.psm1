Function CheckNonStandardUserServices {
    Write-Debug "### Checking for services that do not use standard user accounts..."
    
    $services = Get-WmiObject -Class Win32_Service | Where-Object { 
        ($_.StartName -ne "LocalSystem") -and 
        ($_.StartName -ne "NT AUTHORITY\LocalService") -and 
        ($_.StartName -ne "NT AUTHORITY\NetworkService") -and 
        ($_.StartName -ne $null) -and 
        ($_.StartName -ne "")
    }

    if ($services) {
        Write-Host -ForegroundColor Red "Services were found that use standard user accounts:" 
        $services | Select-Object Name, DisplayName, StartName | ForEach-Object {
            Write-Host -ForegroundColor Red "Service Name: $($_.Name)"
            Write-Host -ForegroundColor Red "Display Name: $($_.DisplayName)"
            Write-Host -ForegroundColor Red "Start Name: $($_.StartName)"
            Write-Host -ForegroundColor Red "-----------------------------------"
            Write-Host -ForegroundColor DarkCyan "Verify via:"
            Write-Host -ForegroundColor DarkCyan "Get-WmiObject -Class Win32_Service | Where-Object {`$_.Name -eq '$($_.Name)'} | Select-Object StartName, DisplayName"
        }
    } else {
        Write-Debug "No services found that do not use standard user accounts. All good."
    }
}
