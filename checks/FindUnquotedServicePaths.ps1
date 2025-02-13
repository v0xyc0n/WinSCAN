Function FindUnquotedServicePaths {
    Write-Debug "### Checking Unquoted Service Paths..." 
    $unquotedPaths = Get-WmiObject win32_service |`
        Select-Object Name,PathName,StartMode,StartName |`
        Where-Object {$_.StartMode -ne "Disabled" -and $_.PathName -notmatch "`"" -and $_.PathName -notmatch "C:\\Windows" -and $_.PathName -notmatch ""}
    
    If ( $unquotedPaths ) { 
        foreach ( $unquotedPath in $unquotedPaths ) {
            Write-Host -ForegroundColor Yellow "Unquoted service path found, examine manually:"
            Write-Host $unquotedPath
        }
        Write-Host -ForegroundColor DarkCyan "Verify via:"
        Write-Host -ForegroundColor DarkCyan "Get-WmiObject win32_service | Select-Object Name, PathName | Where-Object {`$_.Name -eq <Name>}"
    }
    else {
        Write-Debug "All good."
    }
}