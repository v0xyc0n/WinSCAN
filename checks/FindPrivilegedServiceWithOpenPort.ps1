Function FindPrivilegedServiceWithOpenPort {
    Write-Debug "### Looking for Services running as SYSTEM with open ports..."
    $vulnerable = $false

    $servicesAsSystem = Get-WmiObject -Class Win32_Service |
        Where-Object { $_.StartName -eq 'LocalSystem' } |
        Where-Object { $_.PathName -notmatch '^"?(C:\\Windows\\)' } |
        Where-Object { $_.ProcessId -notmatch '^0$' } |
        Select-Object Name, ProcessId

    $ports = netstat -nao

    for ($i=0; $i -lt $servicesAsSystem.count ; $i++) {
        $portsOpenTCP = Write-Output $ports | findstr /r ("LISTENING[^:0-9]*" + $servicesAsSystem[$i].ProcessId.ToString() + "`$")
        if ( $portsOpenTCP ) {
            Write-Host -ForegroundColor Red ("Found open TCP port(s) for SYSTEM service " + $servicesAsSystem[$i].Name + "!")
            Write-Host -ForegroundColor Yellow $portsOpenTCP
            Write-Host ""
            $vulnerable = $true
        }
    }
    if ( $vulnerable ) {
        Write-Host -ForegroundColor DarkCyan "Verify via:"
        Write-Host -ForegroundColor DarkCyan "Get-WmiObject -Class Win32_Service | Where-Object { `$_.StartName -eq 'LocalSystem' } | Where-Object { `$_.ProcessId -eq <ID> }"
        Write-Host -ForegroundColor DarkCyan "`$(& netstat -nao) | findstr /r ('LISTENING[^:0-9]*' + <ID> + '`$')"
    }
}
