Function CheckApplockerForUserWritable {
    Write-Debug "### Searching Applocker for User writable locations..."
    $outputApplocker = ".\output\ApplockerEffective.xml"
    Get-AppLockerPolicy -Effective -Xml > $outputApplocker
    [xml]$ApplockerXML = Get-Content $outputApplocker
    $rules = $ApplockerXML.AppLockerPolicy.RuleCollection
    $filepathRules = $rules.FilePathRule
    $accesschk = "C:\Temp\winSCAN_Temp\accesschk.exe"
    $me = & whoami
    $mySids = ((whoami /groups) | Select-String -Pattern 'S-\d-\d+(-\d+)+').Matches.Value
    $mySids += ((whoami /user) | Select-String -Pattern 'S-\d-\d+(-\d+)+').Matches.Value
    $checkedDirs = @()
    $vulnerable = $false
    $highLevelDirsFound = $false

    $variableMapping = @{
        "%OSDRIVE%" = "$env:SystemDrive"  # Typically, this would be "C:"
        "%WINDIR%" = "$env:SystemRoot"  # Typically the path to Windows
        "%SYSTEM32%" = "C:\Windows\system32\" # No Env variable available
        "%PROGRAMFILES%" = "$env:ProgramFiles"
        "\\\\%LOGONSERVER%" = "$env:LOGONSERVER"  # Just removes the %%
        "\\\*" = "\"  # directories should end with \
    }

    if (! $rules ) {
        Write-Host "Applocker is not active!"
        return
    }

    foreach ($rulecollection in $rules) {
        if ($rulecollection.EnforcementMode -eq "Enabled") {
            $filepathRules = $rulecollection.FilePathRule
        }
        foreach ($filepathRule in $filepathRules) {
            if ($filepathRule.Action -eq "Allow" -and
                $filepathRule.UserOrGroupSid -in $mySids -and 
                -Not $filepathRule.Conditions.FilePathCondition.Path.StartsWith("\\") ) {  # scanning remote dirs is much slower, so we don't (for now)
                
                $directoryPath = $filepathRule.Conditions.FilePathCondition.Path
    
                foreach ( $key in $variableMapping.Keys ) {
                    $directoryPath = $directoryPath -replace $key, $variableMapping[$key]
                }
    
                if ( $directoryPath -like "*\*" -and ( -Not ( $directoryPath -in $checkedDirs ))) { 

                    $checkedDirs += $directoryPath
                    Write-Debug "Checking $directoryPath"

                    if ( ! ( Test-Path -Path $directoryPath ) ) {
                        Write-Host "Path $directoryPath does not exist! Check parent director(ies) for Folder Creation Permission."
                        Write-Host "This has to be done manually, automation might be introduced in the future."
                    }
                    else {
                        if ( $directoryPath.Split('\').Count -lt 4 ) {
                            Write-Host -ForegroundColor Yellow "High-Level directory Allow Rule found for '$directoryPath'. Checking level one subdirectories..."
                            $highLevelDirsFound = $true
                            try {
                                $levelOneDirs = Get-ChildItem -path $directoryPath -directory -ErrorAction "SilentlyContinue"
    
                                foreach ( $levelOneDir in $levelOneDirs ) {
                                    $output = ((& $accesschk /accepteula -nobanner -wud $me $levelOneDir) -split ' ')[0]
                                    if (($output -like "*W*") -or ($output -like "*F*") -and ( -Not ( $levelOneDir -in $checkedDirs ))) {
                                        Write-Host -ForegroundColor Red "User-writable directory found! - $levelOneDir"
                                        Write-Host -ForegroundColor DarkCyan "Verify by copying an exe [example.exe] to $levelOneDir and then execute:"
                                        Write-Host -ForegroundColor DarkCyan "Test-AppLockerPolicy -XMLPolicy '$outputApplocker' -Path '$levelOneDir` example.exe' -User $me"
                                        $vulnerable = $true
                                    }
                                }
                            }
                            catch {} # No Access to directory, doesn't matter
                        }

                        try {
                            if ((get-item $directoryPath -ErrorAction "SilentlyContinue" -Force).PSIsContainer) {
                                $output = ((& $accesschk /accepteula -nobanner -wud $me $directoryPath) -split ' ')[0]
                                if (($output -like "*W*") -or ($output -like "*F*")) {
                                    Write-Host -ForegroundColor Red "User-writable directory found! - $directoryPath"
                                    Write-Host -ForegroundColor DarkCyan "Verify by copying an exe [example.exe] to $directoryPath and then execute:"
                                    Write-Host -ForegroundColor DarkCyan "Test-AppLockerPolicy -XMLPolicy '$outputApplocker' -Path '$directoryPath`example.exe' -User $me"
                                    $vulnerable = $true
                                }
                            }
                            else {
                                $output = ((& $accesschk /accepteula -nobanner -wu $me $directoryPath) -split ' ')[0]
                                if (($output -like "*W*") -or ($output -like "*F*")) {
                                    Write-Host -ForegroundColor Red "User-writable executable found! - $directoryPath"
                                    Write-Host -ForegroundColor DarkCyan "Verify via:"
                                    Write-Host -ForegroundColor DarkCyan "Test-AppLockerPolicy -XMLPolicy '$outputApplocker' -Path '$directoryPath' -User $me"
                                    $vulnerable = $true
                                }
                            }
                        }
                        catch {}  # No access to directory, doesn't matter
                    }
                }    
            }
        }
    }

    if ( $highLevelDirsFound ) {
        Write-Host -ForegroundColor Yellow "`nHigh-Level directory Allow Rules were found! This could be a problem if any subdirectories are writeable."
        Write-Host -ForegroundColor Yellow "Even though direct subdirectories were scanned, writeable subdirectories might exist in a deeper cascading level."
        Write-Host -ForegroundColor Yellow "To check all subdirectories, use accessenum (part of sysinternals)."
        Write-Host -ForegroundColor Yellow "Scan each of the directories and look for non-administrative write-access."
    }
    elseif (! $vulnerable ){
        Write-Debug "All good."
    }
}
