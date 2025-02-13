Function CheckUnencryptedUpdates {
    Write-Debug "### Check if updating is done via HTTP / HTTPS..."
    # Retrieve Windows Update settings
    $wuSettings = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -ErrorAction SilentlyContinue
    $vulnerable = $false

    if ( $wuSettings ) {
        $wuserver = @($wuSettings.WUServer, $wuSettings.WUStatusServer, $wuSettings.UpdateServiceUrlAlternate)
        
        foreach ( $server in $wuserver ) {
            if ($server) {
                if (! $server.StartsWith("https://") ) {
                    Write-Host -ForegroundColor Red "The server for $server does NOT use HTTPS. Updates may not be encrypted."
                    Write-Host -ForegroundColor DarkCyan "Verify via:"
                    Write-Host -ForegroundColor DarkCyan "Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -ErrorAction SilentlyContinue"
                    $vulnerable = $true
                }
            } 
            else {
                Write-Debug "No server configured for $server. Using default Windows Update servers."
                Write-Debug "Default Windows Update servers use HTTPS (encrypted connection)."
            }
        }
    } 
    else {
        Write-Debug "No Windows Update policies are set. Using default Windows Update servers."
        Write-Debug "Default Windows Update servers use HTTPS (encrypted connection)."
    }

    if (! $vulnerable ) {
        Write-Debug "All good."
    }
}