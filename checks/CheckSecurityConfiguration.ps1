Function CheckSecurityConfiguration {
    Write-Debug "### Checking Defender and Hardening Measures..."

    Write-Debug "#### Checking Defender Configuration..."
    if ( Get-MpComputerStatus | Select-Object -ExpandProperty AntivirusEnabled ) {
        Write-Debug "All good."
    }
    else {
        Write-Host -ForegroundColor Red "Defender disabled!"
        Write-Host -ForegroundColor DarkCyan "Verify via:"
        Write-Host -ForegroundColor DarkCyan "Get-MpComputerStatus | Select-Object -ExpandProperty AntivirusEnabled"
    }

    Write-Debug "#### Checking Device Guard Configuration..."
    $deviceGuardStatus = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard | Select-Object -ExpandProperty SecurityServicesRunning
    $vulnerable = $false

    Write-Debug "##### Checking Credential Guard"
    if ($deviceGuardStatus -notcontains 1) {
        Write-Host -ForegroundColor Red "Credential Guard is not running!"
        $vulnerable = $true
    }
    else {
        Write-Debug "All good."
    }
    
    Write-Debug "##### Checking Memory Integrity"
    if ($deviceGuardStatus -notcontains 2) {
        Write-Host -ForegroundColor Red "Memory integrity is not running!"
        $vulnerable = $true
    }
    else {
        Write-Debug "All good."
    }
    
    Write-Debug "##### Checking System Guard Secure Launch"
    if ($deviceGuardStatus -notcontains 3) {
        Write-Host -ForegroundColor Red "System Guard Secure Launch is not running!"
        $vulnerable = $true
    }
    else {
        Write-Debug "All good."
    }
    
    Write-Debug "##### Checking SMM Firmware Measurement"
    if ($deviceGuardStatus -notcontains 4) {
        Write-Host -ForegroundColor Red "SMM Firmware Measurement is not running!"
        $vulnerable = $true
    }
    else {
        Write-Debug "All good."
    }

    Write-Debug "###### Checking Virtualization Based Security Configuration..."
    switch ( Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard | Select-Object -ExpandProperty VirtualizationBasedSecurityStatus ) {
        0 { Write-Host -ForegroundColor Red "VBS is disabled!"; $vulnerable = $true }
        1 { Write-Host -ForegroundColor Red "VBS is enabled but not running!"; $vulnerable = $true }
        2 { Write-Debug "All good." }
    }

    Write-Debug "###### Checking if Powershell Constrained Language Mode is active..."
    if ( $ExecutionContext.SessionState.LanguageMode -ne  "ConstrainedLanguage"){
        Write-Host -ForegroundColor Red "Constrained Language Mode is not active but should be enabled!"
        $vulnerable = $true
    }
    else {
        Write-Debug "All good."
    }

    if ( $vulnerable ) {
        Write-Host -ForegroundColor Red "Insecure Configuration Identified."
        Write-Host -ForegroundColor DarkCyan "Verify via:"
        Write-Host -ForegroundColor DarkCyan "Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard"
    }
}