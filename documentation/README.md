# Documentation

Why it is an issue, how to exploit and further resources.

## Summary

The following contains a comprehensive list of vulnerabilities this script looks for.

### Automatic Checks

These Checks are executed every time the script runs.

* [Always Install Elevated Flag](#checkalwaysinstallelevated)
* [Policy-violating Applocker Policies](#checkapplockerforuserwritable)
* [Enabled CoInstaller](#checkcoinstallerdeactivated)
* [Weak Algorithms used by Kerberos](#CheckKerberosAlgorithms)
* [(Hardening) Enabled/Disabled](#checksecurityconfiguration)
    * [Defender](#defender-configuration)
    * [Credential Guard](#credential-guard)
    * [Memory Integrity](#memory-integrity)
    * [System Guard Secure Launch](#system-guard-secure-launch)
    * [SMM Firmware Measurement](#smm-firmware-measurement)
    * [Virtualization Based Security](#virtualization-based-security-configuration)
    * [Powershell Constrained Language Mode](#powershell-constrained-language-mode)
* [SMBv1, SMB-signing](#checksmbconfiguration)
* [Updates over Unencrypted Connections](#checkunencryptedupdates)
* [User-writable Directories in PATH-variable](#checkuserwriteablepath)
* [Services als SYSTEM User with Open Ports](#findprivilegedservicewithopenport)
* [Secrets in Files](#findsecretsinfiles)
* [Secrets in Registry](#findsecretsinregistry)
* [User-Writable Unquoted Service Paths](#findunquotedservicepaths)

### Manual Checks

This is a reminder for the user what else to check for because automating it is difficult.

* [DMA-Protection](#dma-protection)
* [BIOS-Version up to date](#bios-version)
* [DLL-Hijacking](#dll-hijacking)
* [Network Traffic Analysis](#network-traffic-analysis)
* [Local and shared Secrets](#s)

## Detailed Explanation

### CheckApplockerForUserWritable

This check looks for directories where non-admin users have write- and execute permissions that are excluded from Applocker.

### CheckCoinstallerDeactivated

In the past, if a Razer-mouse was inserted into the computer, it immediately installed third-party software. 
By injecting their own executable, an attacker could coerce the Razer-Software to install malicious software.
Because the installer was running with the highest `SYSTEM`-privileges, this could be used for privilege escalation.

This check looks in the registry if the key `DisableCoInstallers` is set in a secure way, which would mitigate this issue.

### CheckKerberosAlgorithms

This check looks for algorithms used for Kerberos authentication that are considered insecure (aka `RC4`).

### CheckSecurityConfiguration

This check looks for Defender and Device Guard Configuration.

#### Defender Configuration

This check find out if Microsofts AV "Defender" is enabled.

#### Credential Guard

[microsoft.com](https://learn.microsoft.com/en-us/windows/security/identity-protection/credential-guard/)
>Credential Guard prevents credential theft attacks by protecting NTLM password hashes, Kerberos Ticket Granting Tickets (TGTs), and credentials stored by applications as domain credentials.

This check finds out if Credential guard is enabled.

#### Memory Integrity

Memory integrity prevents attackers from inserting malicious code into high-security processes.

This check finds out if Memory Integrity is enabled. 

#### System Guard Secure Launch

System Guard Secure Launch is a Windows feature that uses hardware-based security to ensure a trusted and measured boot process, protecting the system against firmware-level attacks.

This check finds out if System Guard Secure Launch is enabled.

#### SMM Firmware Measurement

SMM Firmware Measurement refers to verifying the integrity of the System Management Mode firmware by measuring its code during boot to detect any unauthorized modifications.

This check finds out if SMM Firmware Measurement is enabled.

#### Virtualization Based Security Configuration

Virtualization Based Security Configuration involves setting up Windows security features that use hardware virtualization to create isolated, 
secure memory regions for critical system processes, enhancing protection against attacks.

This check finds out if Virtualization Based Security Configuration is enabled.

#### Powershell Constrained Language Mode

PowerShell Constrained Language Mode is a security setting that restricts PowerShell's functionality by limiting certain language elements and commands to reduce the risk of executing untrusted scripts.

This check finds out if the Powershell Language Mode is set to Constrained Language.

### CheckSMBConfiguration

This check looks for enabled SMBv1 or missing SMB signing.

### CheckUnencryptedUpdates

The server and the protocol from which wsus updates are pulled is saved at `HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate`.

This check verifies that updates are not pulled via insecure `http`.

### CheckUserWriteablePath

This check inspects the system `Path`-variable and looks for directories that the current user has `write`-access to.
If such a directory is found, it can be abused for [DLL-Hijacking](https://book.hacktricks.xyz/windows-hardening/windows-local-privilege-escalation/dll-hijacking) and therefore privilege escalation.

### FindPrivilegedServiceWithOpenPort

This check first finds all services running with the highest `SYSTEM`-privileges, and then lists those services that also expose ports to the outside.
These carry the risk of an attacker overtaking the system if the service running contains vulnerabilities.

### FindSecretsInFiles

This check looks for passwords in `unattend` and `sysprep` files, where passwords are often stored and forgotten.

### FindSecretsInRegistry

This check looks for saved passwords and saved credentials in the registry.

### FindUnquotedServicePaths

This check looks for service paths that contain spaces, and are unquoted, which under certain conditions enables an attacker to [escalate their privileges](https://www.ired.team/offensive-security/privilege-escalation/unquoted-service-paths).

This check needs improvement (see issues).

### CheckManually

These checks only print to cli and do not present the user with a vulnerabilty assessment.

#### DMA-Protection

From [microsoft.com](https://learn.microsoft.com/en-us/windows/security/hardware-security/kernel-dma-protection-for-thunderbolt):
>Kernel Direct Memory Access (DMA) Protection is a Windows security feature that protects against external peripherals from gaining unauthorized access to memory.

This check prompts the user to find out if DMA protection is enabled.
If DMA-protectiuon is not active, try this: <https://github.com/ufrisk/pcileech>.

#### BIOS-Version

This check will print the current BIOS version and release date.
Go to the vendors page and look for the newest version and security patches released in the meantime.

#### DLL-Hijacking

This check will prompt the user to use `ProcessMonitor`. An explanation of what to do with it can be found [here](https://book.hacktricks.xyz/windows-hardening/windows-local-privilege-escalation/dll-hijacking#finding-missing-dlls). 

#### Network Traffic Analysis

This check prompts the user to log and analyze traffic. Findings can include unencrypted traffic, unknown services or passwords. 

Log with [Wireshark](https://www.wireshark.org/), analyze with [NetworkMiner](https://www.netresec.com/?page=NetworkMiner).

#### Search for Local and shared secrets

This check prompts the user to use [Snaffler](https://github.com/SnaffCon/Snaffler) to look for secrets within all connected resources. Amazing tool, trust me.

Very noisy if it is let loose completely (looks like `Bloodhound` to SOCs). To be a bit more stealthy, use with `-i C:` to just search local disk.
