Function CheckManually {
    Write-Host "### These checks are not (yet) implemented, so you will need to check manually:"
    Write-Host "#### Check if DMA-Protection is enabled: msinfo32.exe"
    Write-Host "#### Check if BIOS-Version is Up-To-Date; check via 'systeminfo | findstr BIOS'"
    Write-Host "#### Check for DLL-hijacking using Procmon (part of sysinternals)"
    Write-Host "#### Fire up wireshark for an hour and look for secrets using 'NetworkMiner'"
    Write-Host "#### Look for secrets on local and smb-drives using 'Snaffler'"
}
