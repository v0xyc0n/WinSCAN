# Changelog

## v1.0.0 - 16.01.2025

### Leaving Alpha

- Tool has been tested in real-life pentests and can be considered stable
- Open issues concern improvements and new checks, all major bugs have been fixed
- Release to the public

### Bug Fixes

- Errors with accesschck do no longer lead to termination
- Verify message for "elevated Processes" now only shows if an issue was found

### New Features

- New Check of Windows Server 2012 extended support
- Log output 

## v0.1.0 - 15.11.2024

### Bug fixes

- Providing accesschck location parameter works now
- Verification command for "elevated Processes" is now only printed if issue was found
- Error with accesschck does not lead to script aborting anymore

### Improvements

- CheckKerberosAlgorithms looks for any RC4 Algorithms now
- Verbosity reduced to put focus on actual findings
- Filter out password false positives 

### New Features

- Help message
- Colors!
- Print command to let users retrace found issues

## v0.0.1 - 23.9.2024

- First Stable release, still pre-alpha and in need of testing.
