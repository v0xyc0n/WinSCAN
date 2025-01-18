Function FindSecretsInFiles {
    Write-Debug "### Looking for Secrets in Files..."

    Write-Debug "#### Looking for passwords in unattend.xml and sysprep.xml ..."
    $possibleLocations = @("\unattend.xml",
                            "\Windows\Panther\Unattend.xml",
                            "\Windows\Panther\Unattend\Unattend.xml",
                            "\Windows\system32\sysprep.inf",
                            "\Windows\system32\sysprep\sysprep.xml"
                            )
    $secretsFound = $false

    foreach ($location in $possibleLocations ) {
        if ( Test-Path $location -PathType Leaf ) {
            $hitsPassword = Select-String -Pattern "password" -Path $location | Select-String -Pattern "\*SENSITIVE\*DATA\*DELETED\*" -NotMatch
            if ( $hitsPassword ) {
                Write-Host -ForegroundColor Red "Found possibly sensitive information in $location`, examine manually:"
                Write-Output $hitsPassword
                $secretsFound = $true
            }
        }
    }

    if (! $secretsFound ) {
        Write-Debug "All good." 
    }
    else {
        Write-Host -ForegroundColor Red "Sensitive Information might have been found"
        Write-Host -ForegroundColor DarkCyan "Verify via:"
        Write-Host -ForegroundColor DarkCyan "Manually looking through found files"
    }
}