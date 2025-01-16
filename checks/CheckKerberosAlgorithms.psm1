Function CheckKerberosAlgorithms {
    Write-Debug "### Checking Kerberos Encryption for weak algorithms..."

    $ticketsContainRC4 = select-string -pattern "RC4" -InputObject (& klist)

    if ( $ticketsContainRC4 ) {
        Write-Host -ForegroundColor Red "Kerberos tickets found using RC4 algorithm! Use 'klist' to verify."
        Write-Host -ForegroundColor DarkCyan "Verify via:"
        Write-Host -ForegroundColor DarkCyan "klist"
    }
    else {
        Write-Debug "All good."
    }

}
