Function CheckSMBConfiguration {
    Write-Debug "### Checking SMB Configuration..."
    
    Write-Debug "#### Checking if SMBv1 is enabled"
    if ( Get-SmbServerConfiguration | Select-Object -ExpandProperty EnableSMB1Protocol ) {
        Write-Host -ForegroundColor Red "The deprecated version SMBv1 is enabled!"
        Write-Host -ForegroundColor DarkCyan "Verify via:"
        Write-Host -ForegroundColor DarkCyan "Get-SmbServerConfiguration | Select-Object -ExpandProperty EnableSMB1Protocol"
    }
    else {
        Write-Debug "All good."
    }

    Write-Debug "#### Checking if SMB signing is enabled"
    if ( -Not ( Get-SmbServerConfiguration | Select-Object -ExpandProperty RequireSecuritySignature ) ) {
        Write-Host -ForegroundColor Red "SMB Signing is not required!"
        Write-Host -ForegroundColor DarkCyan "Verify via:"
        Write-Host -ForegroundColor DarkCyan "Get-SmbServerConfiguration | Select-Object -ExpandProperty RequireSecuritySignature"
    }
    else {
        Write-Debug "All good."
    }
}