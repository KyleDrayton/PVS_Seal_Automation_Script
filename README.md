# SystemMaintenanceAutomation

Comprehensive PowerShell script for Windows system prep, cleanup, and automated reboot with notifications.

## Features
- ✅ SFC and CHKDSK scans
- ✅ Registry tuning (PagefileOnOsVolume, TempPageFile)
- ✅ Event log clearing
- ✅ Local profile cleanup (excludes Administrator, Default, Public, current user)
- ✅ Temp folder cleanup
- ✅ Group Policy refresh
- ✅ Waits for CPU utilization <45% for 2 minutes before reboot
- ✅ Sends notifications via ntfy + triggers HomeSeer events
- ✅ Automated reboot

## Usage
1. Clone the repo or copy `SystemMaintenanceAutomation.ps1`.
2. Run in **elevated PowerShell** (Administrator).
3. Enter your HomeSeer credentials when prompted.
4. Customize:
   - Replace `https://ntfy.example.net/<topic>` with your ntfy server + topic.
   - Replace `https://homeseer.example.net` and `<YourHomeSeerEventName>` with your HomeSeer server and event.
5. Script executes maintenance tasks, sends notifications, and schedules a reboot.

## Notes
- Some steps require elevated rights (Admin).
- Customize exclusion list in `Delete-LocalUserProfiles`.
- Notifications rely on accessible ntfy + HomeSeer setup.
- 
- 🔒 Notifications in this script use [ntfy](https://ntfy.sh/) as an example webhook endpoint. 
It can be self-hosted (as shown here) or swapped for a corporate-approved service such as 
Teams, Slack, or ServiceNow to align with enterprise security policies.

---

Author: Kyle Drayton  
GitHub: [https://github.com/kyledrayton](https://github.com/kyledrayton)
