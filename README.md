# PVS Seal Automation Script

PowerShell script to prepare and clean a Windows system before imaging or sealing (cleanup, maintenance scans, notifications, and automated reboot).

Script file in this repository: `PVS_Seal_Automation_Script.ps1`

## Features
- SFC and CHKDSK scans
- Registry tuning (pagefile related settings)
- Event log clearing
- Local profile cleanup (excludes Administrator, Default, Public, and the current user)
- Temp folder cleanup
- Group Policy refresh
- Waits for low CPU before reboot (helps avoid rebooting during heavy activity)
- Sends notifications via ntfy and triggers HomeSeer events (configurable)
- Automated reboot when maintenance completes

## Requirements
- Windows (the script is intended for Windows hosts)
- PowerShell: Windows PowerShell 5.1 or PowerShell 7+ on Windows
- Administrative (elevated) privileges to perform system maintenance tasks
- Network access to your notification endpoint (ntfy or alternative) and HomeSeer server if used

## Quick start (run)
1. Open an elevated PowerShell prompt (Run as Administrator).
2. From the folder containing the script, run:

```powershell
# Launch elevated PowerShell and run the script (example)
Start-Process powershell -Verb runAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File .\PVS_Seal_Automation_Script.ps1'
```

Or, if you're already elevated:

```powershell
.\PVS_Seal_Automation_Script.ps1
```

Notes:
- The script may prompt for HomeSeer credentials or other interactive input depending on configuration.
- If your environment enforces execution policy, use `-ExecutionPolicy Bypass` as shown above to run this one-off script.

## Configuration
Before running, edit the top of `PVS_Seal_Automation_Script.ps1` (or variables near the top of the script) to set your environment values. Typical variables to review:

- `$NtfyUrl` — the ntfy endpoint or topic, e.g. `https://ntfy.example.net/your-topic`
- `$HomeSeerBaseUrl` — your HomeSeer server base URL, e.g. `https://homeseer.example.net`
- `$HomeSeerEventName` — the event name to trigger in HomeSeer
- `$ExcludeProfiles` — array of local profile names to exclude from deletion (Administrator, Default, Public, and the current user are usually excluded by default)

Search near the top of the script file for these variable names and update them for your environment.

## Safety & Notes
- Run this script only when you intend to make system-wide changes and reboot the machine.
- The script performs destructive operations such as profile deletion and event-log clearing. Review and test in a lab before production use.
- Notifications use `ntfy` in examples; you can replace that with Teams, Slack, ServiceNow, or any corporate-approved system. Ensure URLs and authentication methods match your policy.

## Troubleshooting
- If the script exits early, check the PowerShell console for the error details and ensure you ran an elevated session.
- If notifications fail, verify network connectivity and that your ntfy/HomeSeer endpoints are reachable from the target machine.

## Author
Kyle Drayton
GitHub: https://github.com/KyleDrayton
