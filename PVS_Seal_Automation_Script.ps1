<#
.SYNOPSIS
    End-to-end Windows maintenance script with automation and notifications.

.DESCRIPTION
    Runs a sequence of system prep/maintenance steps:
    - SFC and CHKDSK scans
    - Registry adjustments (PagefileOnOsVolume, TempPageFile)
    - Event log clearing
    - Local profile cleanup (excluding default/system/current user)
    - Temp directory cleanup
    - Group Policy refresh
    - CPU utilization check before reboot
    - ntfy + HomeSeer integration for notifications
    - Automated reboot

.NOTES
    Author: Kyle Drayton
    GitHub: https://github.com/kyledrayton
#>

# Prompt for HomeSeer credentials
$credential = Get-Credential -Message "Enter your HomeSeer credentials"

function Run-SFCScan {
    Write-Host "Starting System File Checker (SFC) scan..." -ForegroundColor Cyan
    sfc /scannow
    Write-Host "SFC scan completed." -ForegroundColor Green
}

function Run-CHKDSK {
    Write-Host "Starting Check Disk (CHKDSK) with the /F flag..." -ForegroundColor Cyan
    echo Y | chkdsk C: /F
    Write-Host "CHKDSK completed or scheduled for next reboot." -ForegroundColor Green
}

function Modify-RegistryEntries {
    $registryPath = "HKLM:\System\CurrentControlSet\Control\Session Manager\Memory Management"
    if (-not (Test-Path $registryPath)) {
        Write-Host "Registry path does not exist. Exiting..." -ForegroundColor Red
        exit
    }
    Set-ItemProperty -Path $registryPath -Name "PagefileOnOsVolume" -Value 1
    Set-ItemProperty -Path $registryPath -Name "TempPageFile" -Value 0
    Write-Host "Registry entries updated." -ForegroundColor Green
}

function Clear-EventLogs {
    Get-WinEvent -ListLog * | ForEach-Object {
        wevtutil cl $($_.LogName)
    }
    Write-Host "Event logs cleared." -ForegroundColor Green
}

function Delete-LocalUserProfiles {
    $currentUser = $env:USERNAME
    $excludeUsers = @("Administrator", "Default", "Public", $currentUser)
    $profiles = Get-WmiObject Win32_UserProfile | Where-Object { $_.Special -eq $false -and $_.LocalPath }

    foreach ($profile in $profiles) {
        $userName = $profile.LocalPath.Split("\")[-1]
        if ($excludeUsers -notcontains $userName) {
            try { $profile.Delete(); Write-Host "Deleted profile: $userName" -ForegroundColor Green }
            catch { Write-Host "Failed to delete profile: $userName" -ForegroundColor Red }
        }
    }
}

function Delete-TempContents {
    $TempDir = "C:\temp"
    if (Test-Path $TempDir) {
        try { Remove-Item "$TempDir\*" -Force -Recurse; Write-Host "Temp cleared." -ForegroundColor Green }
        catch { Write-Host "Failed to clear temp: $_" -ForegroundColor Red }
    }
}

function Force-GroupPolicyUpdate {
    gpupdate /force /wait:0
    Write-Host "Group Policy updated." -ForegroundColor Green
}

function WaitFor-LowCPUUtilization {
    Write-Host "Waiting for CPU < 45% for 2 minutes..." -ForegroundColor Cyan
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    while ($true) {
        $cpu = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples[0].CookedValue
        if ($cpu -lt 45) {
            if ($timer.Elapsed.TotalMinutes -ge 2) { break }
        } else { $timer.Restart() }
        Start-Sleep -Seconds 10
    }
}

function Send-ntfyNotification {
    try {
        # 🔒 Replace with your actual ntfy topic
        Invoke-RestMethod -Uri 'https://ntfy.example.net/<topic>' -Method POST -Body 'Maintenance Complete!' -TimeoutSec 10
        Write-Host "ntfy notification sent." -ForegroundColor Green

        # 🔒 Replace with your actual HomeSeer server + event
        $homeseerUrl = "https://homeseer.example.net"
        $eventName = "<YourHomeSeerEventName>"
        $url = "$homeseerUrl/JSON?request=runevent&name=$eventName"
        $response = Invoke-RestMethod -Uri $url -Method Get -Credential $credential
        if ($response) { Write-Host "HomeSeer event triggered: $eventName" -ForegroundColor Green }
    } catch { Write-Host "Notification failed: $_" -ForegroundColor Red }
}

function Reboot-System {
    shutdown /r /t 60
    Write-Host "Reboot scheduled in 60 seconds." -ForegroundColor Yellow
}

# === Main Execution ===
Run-SFCScan
Run-CHKDSK
Modify-RegistryEntries
Clear-EventLogs
Delete-LocalUserProfiles
Delete-TempContents
Force-GroupPolicyUpdate
WaitFor-LowCPUUtilization
Send-ntfyNotification
Reboot-System
