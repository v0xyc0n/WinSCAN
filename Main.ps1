<#
.SYNOPSIS
    Collection of scripts to help with pentesting Windows.
.DESCRIPTION
    .
.PARAMETER EnableAggressiveChecks
    Specifies whether aggressive checks schould be run. Aggressive checks 
    require a long time to complete, sometimes >1h. Set to True to enable 
    aggressive checks.
.PARAMETER LocationAccesschck
    Specifies the absolute path to accesschk.exe. By default accesschk is 
    searched for at same directory Main.ps1 is located in.
.EXAMPLE
    C:\PS> ./Main.ps1 -LocationAccesschck 'Path\To\accesschk'
    Execute with default configuration
.NOTES
    Author: Jakob Pachmann
    Date:   August 27, 2024
#>

param (
    [switch] $EnableAggressiveChecks = $false,
    [string] $LocationAccesschck = ".\accesschk.exe"
)

$Temp = "C:\Temp\winSCAN_Temp"
$Output = "$PSScriptRoot\output"
$modulePath = ".\checks"
$checks = @()
Function Main() {
    Get-ChildItem -Path $modulePath -Recurse -Filter *.ps1 | ForEach-Object {
        try {
            . $_.FullName -ErrorAction Stop
            $checks = $checks + $_.BaseName
            Write-Debug "Successfully loaded check: $($_.FullName)"
        }
        catch {
            Write-Error "Failed to load check: $($_.FullName)"
        }
    }
    
    Write-Host "
     __      __.__         __________________     _____    _______   
    /  \    /  \__| ____  /   _____/\_   ___ \   /  _  \   \      \  
    \   \/\/   /  |/    \ \_____  \ /    \  \/  /  /_\  \  /   |   \ 
     \        /|  |   |  \/        \\     \____/    |    \/    |    \
      \__/\  / |__|___|  /_______  / \______  /\____|__  /\____|__  /
           \/          \/        \/         \/         \/         \/ 
            WinSCAN - Pentesting Assistant for Windows 
    "
        
    if ( $EnableAggressiveChecks ) {
        Write-Host "## Agressive checks enabled ##"
    }
    
    If (! (Test-Path -Path $Output) ) {
        mkdir $Output > $null
    }
    
    If (! (Test-Path -Path $Temp) ) {
        mkdir $Temp > $null
    }
    
    $user = (whoami).split("\")[1]
    if ( $user -like "*admin*" ) {
        $Cont = Read-Host "Running this script in an elevated shell might lead to some checks not working as intended. 
            Some results will probably throw false positives. Continue anyways? (y/n)"
        if ( $Cont -ne "y" ) {
            exit
        }
    }
    
    if (! (Test-Path $Temp\accesschk.exe -PathType Leaf)) {
        try {
            Copy-Item $LocationAccesschck "$Temp\accesschk.exe" -ErrorAction Stop
        }
        catch {
            $Cont = Read-Host "Accesschck was not found at provided location $LocationAccesschck, some checks will not run as intended.
                To provide a location manually, execute the script like this: ./Main.ps1 -LocationAccesschck '<Path_To_accesschk_exe>'
                Continue without accesschck? (y/n)"
            if ( $Cont -ne "y" ) {
                exit
            }
        }
    }
    
    try {
        $applockerDecision = Get-AppLockerPolicy -Effective | Test-AppLockerPolicy -Path $Temp/*.exe -User $user | Select-Object -ExpandProperty PolicyDecision
        if ( $applockerDecision -and ($applockerDecision -ne "Allowed") ) {
            Write-Host "$Temp seems to be blocked by applocker. Please add the folder for the script to run properly.`
                To do this, you will probably need to execute `secpol.msc` as Administrator.`
                The tool will continue running, but results of some checks might be wrong and need to be manually verified."
        }
    } catch {
        Write-Host "There might have been a problem in copying accesschk.`
        The tool will continue running, but results of some checks might be wrong and need to be manually verified."
    }
    
    # For Reporting
    Write-Host "`n## ---- User-Info ---- ##"
    whoami
    Get-Date -Format "d"
    Get-Date -Format "t"
    Write-Host "$env:COMPUTERNAME.$env:USERDNSDOMAIN"
    Write-Host "## ------------------- ##`n`n"
    
    # Where the magic happens
    $manualChecks = @()
    foreach ( $check in $checks ) {
        switch -wildcard ( $check ) {
            "*Manual*" { # safe it for the end
                $manualChecks += $check
            }
            "*_aggressive" {
                if ( $EnableAggressiveChecks ) {
                    $Cont = Read-Host "The check 'FindEditableLogonScripts' takes a very long time (~ 1h). run anyways?"
                    if ( $Cont -eq "y" ) {
                        try {
                            Write-Host "## --------------------- Executing check: $check --------------------- ##"
                            & $check
                            Write-Host "## ------------------ $check executed successfully. ------------------ ##`n`n`n"
                        }
                        catch {
                            Write-Error "Failed to execute function: $check"
                            Write-Error "Error: $_"
                        }
                    }
                }
            }
            default {
                try {
                    Write-Host "## --------------------- Executing check: $check --------------------- ##"
                    & $check
                    Write-Host "## ------------------ $check executed successfully. ------------------ ##`n`n`n"
                }
                catch {
                    Write-Error "Failed to execute function: $check"
                    Write-Error "Error: $_"
                }
            }
        }
    }
    
    Write-Host "## --------------------- Running Manual Checks --------------------- ##"
    foreach ( $check in $manualChecks ) {
        try {
            Write-Host "## --------------------- Executing check: $check --------------------- ##"
            & $check
            Write-Host "## ------------------ $check executed successfully. ------------------ ##`n`n`n"
        }
        catch {
            Write-Error "Failed to execute function: $check"
            Write-Error "Error: $_"
        }
    }
    
    Write-Host "Done; cleaning up."
    Remove-Item $Temp -r -force    
}

try {
    Start-Transcript -Path ".\output\Transcript-$($((Get-Date).ToString('yyyyMMdd_HHmmss'))).log"
    Main
}
finally {
    Stop-Transcript
}
