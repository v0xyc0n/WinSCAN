# WinSCAN - Pentesting Assistant for Windows

Script to help with W11 Pentests. Checks include poking holes in Applocker rules, digging for secrets and checking shares permissions. 

Full list of checks can be found in the [documentation](./documentation).

## How do I run it?

`./Main.ps1 -LocationAccesschck <Path_To_accesschk_exe>`

## I have limited access to a hardened system, will the tool work?

PAW is designed to run with as limited permissions as possible. You 
- Do not need admin-privileges
- Do not need to create any Defender exceptions
- Do not need to downgrade powershell or disable constrained language mode

All you need is access to powershell.

## How Do I interpret the results?

Have a look at the [documentation](./documentation). 
Every found issue also comes with a Powershell One-Liner for you to execute to prove the vulnerability really exists.

## Why?

Why make a tool at all?
- Takes away tedious, repeatable work and lets a pentester focus on the interesting things 
- Findings from past pentests can easily be incorporated and will therefore never be forgotten in the future
- Establishes a baseline - pentesters will focus on different stuff and this makes sure some checks are always executed

There a a ton of tools for similar purposes like Nessus or WinPEAS. Why make a new one?
- Doesn't get detected and blocked by Defender (yet)
- Does not rely on third-party software where not absolutely necessary 
- Code is modular and easily understandable (in part because I don't know how to do complex code) -Therefore:
    - Easy to expand by new checks (see below)
    - Easy to expand by new functionality like automatic report generation
- Quick to deploy and easy to use
- Includes code-snippet to include in your report to ensure reproducibility
- Fast execution - from download to finished report in 30 seconds
- Can work as a kind of documentation (which checks were run in which test?)
- Much cheaper (0€) than nessus
- No historical debt

## Checks

Checks are small, capsuled security tests. Output of these checks should be as short as possible to avoid cluttering up the output and as verbose as necessary to inform the user which checks are run and if there were any problems encountered. As a future goal is automatic report generation, the information collected by a check should be summarizable in one Finding.

There is a `verbose` Mode, which reveals much more information and is usually only needed for debugging purposes. To access it, use:

```powershell
$DebugPreference = 'Continue' #Set Debug true
./Main.ps1
$DebugPreference = 'SilentlyContinue' # Set Debug false after execution
```

## Contribution

The main branch is protected, so you will need to create a new one and open a merge request. To ensure everything is documented, please create a new issue for any contribution, be it a new check or code adjustments. 

If you want to add checks, it is as simple as creating a new powershell module in `./checks/` or in any of its subfolders. 
Each added module should only contain one function ("=check"), and the name of this function must match the name of the module.
The reason for this is that the basename (everything before `.psm1`) is used to call the check.

All checks in the `checks` folder (or any subfolders) are automatically executed, so there is no need for any additional configuration.

### Special Checks

If your security-check is potentially disruptive to the systems' stability or takes a long time complete, add the string `_aggressive` to the end of the checks name.
This ensures that this check is only run with the users explicit permission.

If you want to add instructions for the user what to look for, but you don't want to script it out, include the string `Manual` in the checks name.
These "checks" are executed after all automatic checks have finished.

### Example

To add a new check called `CheckSanity`, add a new file in the folder `/checks/`:

`./checks/CheckSanity.psm1`

With content:

```powershell
Function CheckSanity {
    Write-Host "Sanity intact. Carry on."
}
```

## Changelog

Changelog can be found [here](./documentation/Changelog.md). Version increments follow the semantic rule of `<MAJOR>.<MINOR>.<PATCH>`.

If only bugs were fixed and the previous version was `0.0.1`, the next version will be `0.0.2`.

If a feature was implemented and the previous version was `0.0.1`, the next version will be `0.1.0`.

A major change is not clearly defined, but could be the step from `alpha` or `beta`-version to `production-ready`.
