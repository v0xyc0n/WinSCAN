Function FindSecretsInRegistry {
    Write-Debug "### Looking for Secrets in Registry..."

    Write-Debug "`n#### Looking for keys with string 'assw'..."
    # Defender kills any search for "pass"
    # Get-Item would be much easier because the result gets split in properties
    # but unfortunately, for such a large search space it is too slow.

    $regPasswords = reg query HKLM /v *assw* /t REG_SZ /s
    $regPasswords += reg query HKU /v *assw* /t REG_SZ /s
    $filteredRegPasswords = $()

    # Filter out False Positives
    for ( $i = 0; $i -lt $regPasswords.Count; $i++ ) { # Line-By-Line
        if ( $regPasswords[$i] | Select-String 'REG_SZ') { # Line Contains Registry entry
            if ( $regPasswords[$i] | Select-String -NotMatch 'REG_SZ\s*($|\*$|true|false|true,false|no)' ) { 
                $filteredRegPasswords += $regPasswords[$i - 1] + "`n" + $regPasswords[$i] # $regPasswords[$i - 1] contains path
            }
        }
    }

    if ( $filteredRegPasswords ) {
        Write-Host -ForegroundColor Red "Possible hits found, please examine manually:"
        Write-Output $filteredRegPasswords
        Write-Host -ForegroundColor DarkCyan "Verify via:"
        Write-Host -ForegroundColor DarkCyan "reg query <Registry_Path>"
    }
    else {
        Write-Debug "All good."
    }

    Write-Debug "`n#### Looking for saved credentials in 'Winlogon'..."
    $winlogonRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    try {
        $winlogonVulnerable = $false
        $winlogonKeys = Get-ItemProperty -Path $winlogonRegPath

        if ( $winlogonKeys.AutoAdminLogon -eq 1 ) {
            Write-Debug"Automatic Admin Login enabled! Check for saved credentials at $regPath"
            $winlogonVulnerable = $true
        }

        if ( $winlogonKeys.DefaultUserName ) {
            Write-Debug "Default username '$($winlogonKeys.DefaultUserName)' found!"
            $winlogonVulnerable = $true
        }

        if ( $winlogonKeys.DefaultPassword ) {
            Write-Host -ForegroundColor Red "Default password '$($winlogonKeys.DefaultPassword)' found!"
            $winlogonVulnerable = $true
            Write-Host -ForegroundColor DarkCyan "Verify via:"
            Write-Host -ForegroundColor DarkCyan "Get-ItemProperty -Path '$winlogonRegPath'"
        }
            
        if ( ! $winlogonVulnerable ) {
            Write-Debug "All good."
        }
    }
    catch {
        Write-Host $_.Exception.Message
    }


    Write-Debug "`n#### Looking snmp configuration..."
    $snmpRegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters"
    $snmpRegKeys = Get-ItemProperty -Path $snmpRegPath -ErrorAction SilentlyContinue

    if ( $snmpRegKeys ) {
        Write-Host "SNMP Configuration found!"
        Write-Host -ForegroundColor DarkCyan "Verify via:"
        Write-Host -ForegroundColor DarkCyan "Get-ItemProperty -Path '$snmpRegPath'"
    }    
    else {
        Write-Debug "SNMP Configuration was not found. All good."
    }


    Write-Debug "`n#### Looking realvnc configuration..."
    $vncRegPath = "HKLM:\SOFTWARE\RealVNC\WinVNC4"

    # Check if the key exists
    if (Test-Path $vncRegPath) {
        $vncSettings = Get-ItemProperty -Path $vncRegPath
        if ($vncSettings.Password) {
            Write-Host "Encrypted password found. Review for potential vulnerabilities."
            Write-Host -ForegroundColor DarkCyan "Verify via:"
            Write-Host -ForegroundColor DarkCyan "Get-ItemProperty -Path '$vncRegPath'"
        } else {
            Write-Host "All good."
        }
    }
    else {
        Write-Debug "RealVNC is not installed or registry key not found. All good."
    }   

}