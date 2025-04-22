#requires -Version 5.1

<#
.SYNOPSIS
    Example usage of the Sleepy PowerShell module
.DESCRIPTION
    This script demonstrates how to use the Sleepy PowerShell module programmatically.
.NOTES
    Author: NT_AUTHORITY
    Version: 1.0.0
#>

# Import the module
Import-Module -Name (Join-Path $PSScriptRoot "Sleepy.psm1") -Force

# Set configuration
# Uncomment one of the following lines to enable different debug levels:

# Basic configuration (no debug)
Set-SleepyConfig -ApiUrl "http://localhost:8080" -Secret "YourSecretHere"

# Enable debug mode for basic request/response logging
# Set-SleepyConfig -ApiUrl "http://localhost:8080" -Secret "YourSecretHere" -DebugMode
# Write-Host "Debug mode is enabled. You will see detailed logging information." -ForegroundColor Yellow

# Enable full debug mode for complete request/response details
# Set-SleepyConfig -ApiUrl "http://localhost:8080" -Secret "YourSecretHere" -FullDebugMode
# Write-Host "Full debug mode is enabled. You will see complete request/response details." -ForegroundColor Yellow

# Example 1: Get current status
Write-Host "Example 1: Get current status" -ForegroundColor Cyan
$status = Get-SleepyStatus
if ($null -ne $status) {
    Write-Host "Current status: $($status.info.name) ($($status.status))" -ForegroundColor Green
    Write-Host "Last updated: $($status.last_updated)" -ForegroundColor Green

    Write-Host "Devices:" -ForegroundColor Yellow
    foreach ($deviceProp in $status.device.PSObject.Properties) {
        $device = $deviceProp.Value
        $deviceId = $deviceProp.Name

        $deviceStatus = if ($device.using -eq $true) {
            "Using $($device.app_name)"
        }
        else {
            "Not in use"
        }

        Write-Host "  $($device.show_name) ($deviceId): $deviceStatus" -ForegroundColor Gray
    }
}

# Example 2: Get available status list
Write-Host "`nExample 2: Get available status list" -ForegroundColor Cyan
$statusList = Get-SleepyStatusList
if ($null -ne $statusList) {
    Write-Host "Available statuses:" -ForegroundColor Yellow
    foreach ($statusItem in $statusList) {
        Write-Host "  $($statusItem.id): $($statusItem.name) - $($statusItem.desc)" -ForegroundColor Gray
    }
}

# Example 3: Set status
Write-Host "`nExample 3: Set status" -ForegroundColor Cyan
Write-Host "Setting status to 0 (usually 'Awake' or similar)..." -ForegroundColor Yellow
$setStatusResult = Set-SleepyStatus -StatusId 0
if ($null -ne $setStatusResult -and $setStatusResult.success) {
    Write-Host "Status set successfully to $($setStatusResult.set_to)" -ForegroundColor Green
}
else {
    Write-Host "Failed to set status" -ForegroundColor Red
}

# Example 4: Update device status
Write-Host "`nExample 4: Update device status" -ForegroundColor Cyan
Write-Host "Setting device 'device-1' as using PowerShell..." -ForegroundColor Yellow
$setDeviceResult = Set-SleepyDeviceStatus -Id "device-1" -ShowName "My Computer" -Using $true -AppName "PowerShell"
if ($null -ne $setDeviceResult -and $setDeviceResult.success) {
    Write-Host "Device status updated successfully" -ForegroundColor Green
}
else {
    Write-Host "Failed to update device status" -ForegroundColor Red
}

# Example 5: Save data
Write-Host "`nExample 5: Save data" -ForegroundColor Cyan
Write-Host "Saving data to persistent storage..." -ForegroundColor Yellow
$saveDataResult = Save-SleepyData
if ($null -ne $saveDataResult -and $saveDataResult.success) {
    Write-Host "Data saved successfully" -ForegroundColor Green
    Write-Host "Saved data: $($saveDataResult.data | ConvertTo-Json -Depth 3)" -ForegroundColor Gray
}
else {
    Write-Host "Failed to save data" -ForegroundColor Red
}

Write-Host "`nAll examples completed." -ForegroundColor Cyan
