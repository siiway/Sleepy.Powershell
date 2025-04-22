#requires -Version 5.1

<#
.SYNOPSIS
    Sleepy Control Panel - A PowerShell-based control panel for Sleepy API
.DESCRIPTION
    This script provides a user-friendly interface to interact with the Sleepy API,
    allowing you to manage your status, devices, and other settings.
.NOTES
    Author: Augment Agent
    Version: 1.0
#>

# Configuration
$script:Config = @{
    ApiUrl = "http://localhost:9010"  # Default API URL, can be changed in settings
    Secret = ""                       # Secret for authentication, can be set in settings
    RefreshInterval = 5               # Refresh interval in seconds
    DebugMode = $false                # Debug mode flag, enables detailed logging
    FullDebugMode = $false           # Full debug mode flag, enables complete request/response logging
}

# Function to load configuration from file
function Load-Configuration {
    $configPath = Join-Path $PSScriptRoot "sleepy-config.json"
    if (Test-Path $configPath) {
        try {
            $loadedConfig = Get-Content $configPath -Raw | ConvertFrom-Json
            $script:Config.ApiUrl = $loadedConfig.ApiUrl
            $script:Config.Secret = $loadedConfig.Secret
            $script:Config.RefreshInterval = $loadedConfig.RefreshInterval

            # Load debug mode if it exists in the config file
            if (Get-Member -InputObject $loadedConfig -Name "DebugMode" -MemberType Properties) {
                $script:Config.DebugMode = $loadedConfig.DebugMode
            }

            # Load full debug mode if it exists in the config file
            if (Get-Member -InputObject $loadedConfig -Name "FullDebugMode" -MemberType Properties) {
                $script:Config.FullDebugMode = $loadedConfig.FullDebugMode
            }

            Write-Host "Configuration loaded successfully." -ForegroundColor Green
        }
        catch {
            Write-Host "Error loading configuration: $_" -ForegroundColor Red
        }
    }
}

# Function to save configuration to file
function Save-Configuration {
    $configPath = Join-Path $PSScriptRoot "sleepy-config.json"
    try {
        $script:Config | ConvertTo-Json | Set-Content $configPath
        Write-Host "Configuration saved successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Error saving configuration: $_" -ForegroundColor Red
    }
}

# Function to write debug information
function Write-DebugInfo {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [System.ConsoleColor]$ForegroundColor = [System.ConsoleColor]::DarkCyan,

        [Parameter(Mandatory = $false)]
        [switch]$FullDebugOnly
    )

    if ($script:Config.DebugMode) {
        if (-not $FullDebugOnly -or ($FullDebugOnly -and $script:Config.FullDebugMode)) {
            Write-Host "[DEBUG] $Message" -ForegroundColor $ForegroundColor
        }
    }
}

# Function to wait for user input when in full debug mode
function Wait-ForUserInput {
    param (
        [Parameter(Mandatory = $false)]
        [int]$DefaultWaitSeconds = 2,

        [Parameter(Mandatory = $false)]
        [string]$Message = "Press any key to continue..."
    )

    if ($script:Config.FullDebugMode) {
        # In full debug mode, wait for user input
        Write-Host ""
        Write-Host $Message -ForegroundColor DarkYellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    else {
        # In normal mode, just wait the default time
        Start-Sleep -Seconds $DefaultWaitSeconds
    }
}

# Helper function to make API requests
function Invoke-SleepyApi {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Endpoint,

        [Parameter(Mandatory = $false)]
        [string]$Method = "GET",

        [Parameter(Mandatory = $false)]
        [object]$Body = $null,

        [Parameter(Mandatory = $false)]
        [switch]$RequiresAuth = $false,

        [Parameter(Mandatory = $false)]
        [hashtable]$QueryParams = @{}
    )

    $uri = "$($script:Config.ApiUrl)/$($Endpoint.TrimStart('/'))"
    Write-DebugInfo "API Request: $Method $uri"

    # Add authentication if required
    $headers = @{}
    if ($RequiresAuth) {
        if ([string]::IsNullOrEmpty($script:Config.Secret)) {
            Write-Host "Authentication required but no secret is configured." -ForegroundColor Red
            return $null
        }
        $BearerToken = "Bearer $($script:Config.Secret)"
        $headers["Authorization"] = $BearerToken
        Write-DebugInfo "Added authentication header"
    }

    # Add query parameters
    if ($QueryParams.Count -gt 0) {
        $queryString = [System.Web.HttpUtility]::ParseQueryString([string]::Empty)
        foreach ($key in $QueryParams.Keys) {
            $queryString.Add($key, $QueryParams[$key])
            Write-DebugInfo "Added query parameter: $key = $($QueryParams[$key])"
        }
        $uriBuilder = New-Object System.UriBuilder($uri)
        $uriBuilder.Query = $queryString.ToString()
        $uri = $uriBuilder.Uri.ToString()
        Write-DebugInfo "Final URI with query parameters: $uri"
    }

    # Prepare request parameters
    $params = @{
        Uri = $uri
        Method = $Method
        Headers = $headers
        ContentType = "application/json"
        ErrorAction = "Stop"
    }

    # Add body if provided
    if ($null -ne $Body) {
        if ($Method -eq "GET") {
            Write-Warning "Body parameter ignored for GET request."
        }
        else {
            $bodyJson = $Body | ConvertTo-Json
            $params.Body = $bodyJson
            Write-DebugInfo "Request body: $bodyJson"
        }
    }

    try {
        Write-DebugInfo "Sending request to $uri"

        # Log full request details in full debug mode
        if ($script:Config.FullDebugMode) {
            Write-DebugInfo "Full request details:" -FullDebugOnly
            Write-DebugInfo "  Method: $Method" -FullDebugOnly
            Write-DebugInfo "  URI: $uri" -FullDebugOnly
            Write-DebugInfo "  Headers: $(ConvertTo-Json -InputObject $headers -Compress)" -FullDebugOnly

            if ($params.ContainsKey('Body')) {
                Write-DebugInfo "  Body: $($params.Body)" -FullDebugOnly
            }
            else {
                Write-DebugInfo "  Body: None" -FullDebugOnly
            }

            Write-DebugInfo "  ContentType: $($params.ContentType)" -FullDebugOnly
            Write-DebugInfo "  ErrorAction: $($params.ErrorAction)" -FullDebugOnly
        }

        $response = Invoke-RestMethod @params

        # Log response in debug mode
        if ($script:Config.DebugMode) {
            $responseJson = $response | ConvertTo-Json -Depth 3
            Write-DebugInfo "Response received: $responseJson" -ForegroundColor DarkGreen

            # Log full response details in full debug mode
            if ($script:Config.FullDebugMode) {
                Write-DebugInfo "Full response details:" -FullDebugOnly
                Write-DebugInfo "  StatusCode: 200 (OK)" -FullDebugOnly
                Write-DebugInfo "  Content: $responseJson" -FullDebugOnly
            }
        }

        return $response
    }
    catch {
        Write-Host "API request failed: $_" -ForegroundColor Red
        Write-DebugInfo "API request failed with error: $_" -ForegroundColor Red

        # Log full exception details in full debug mode
        if ($script:Config.FullDebugMode) {
            Write-DebugInfo "Full exception details:" -FullDebugOnly
            Write-DebugInfo "  Exception Type: $($_.Exception.GetType().FullName)" -FullDebugOnly
            Write-DebugInfo "  Message: $($_.Exception.Message)" -FullDebugOnly
            Write-DebugInfo "  StackTrace: $($_.Exception.StackTrace)" -FullDebugOnly

            if ($_.InvocationInfo) {
                Write-DebugInfo "  ScriptName: $($_.InvocationInfo.ScriptName)" -FullDebugOnly
                Write-DebugInfo "  Line: $($_.InvocationInfo.ScriptLineNumber)" -FullDebugOnly
                Write-DebugInfo "  Position: $($_.InvocationInfo.OffsetInLine)" -FullDebugOnly
                Write-DebugInfo "  Line Content: $($_.InvocationInfo.Line)" -FullDebugOnly
            }
        }

        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
            $statusDescription = $_.Exception.Response.StatusDescription
            Write-Host "Status Code: $statusCode - $statusDescription" -ForegroundColor Red
            Write-DebugInfo "HTTP Status: $statusCode - $statusDescription" -ForegroundColor Red

            # Log full response details in full debug mode
            if ($script:Config.FullDebugMode) {
                Write-DebugInfo "Full response details:" -FullDebugOnly
                Write-DebugInfo "  StatusCode: $statusCode" -FullDebugOnly
                Write-DebugInfo "  StatusDescription: $statusDescription" -FullDebugOnly
                Write-DebugInfo "  ResponseUri: $($_.Exception.Response.ResponseUri)" -FullDebugOnly
                Write-DebugInfo "  Server: $($_.Exception.Response.Server)" -FullDebugOnly
                Write-DebugInfo "  ContentType: $($_.Exception.Response.ContentType)" -FullDebugOnly
                Write-DebugInfo "  ContentLength: $($_.Exception.Response.ContentLength)" -FullDebugOnly
            }

            try {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $responseBody = $reader.ReadToEnd()
                Write-Host "Response: $responseBody" -ForegroundColor Red
                Write-DebugInfo "Error response body: $responseBody" -ForegroundColor Red
            }
            catch {
                Write-Host "Could not read response body." -ForegroundColor Red
                Write-DebugInfo "Failed to read error response body: $_" -ForegroundColor Red
            }
        }
        return $null
    }
}

# Function to get current status
function Get-SleepyStatus {
    $response = Invoke-SleepyApi -Endpoint "query"
    return $response
}

# Function to get available status list
function Get-SleepyStatusList {
    $response = Invoke-SleepyApi -Endpoint "status_list"
    return $response
}

# Function to set status
function Set-SleepyStatus {
    param (
        [Parameter(Mandatory = $true)]
        [int]$StatusId
    )

    $response = Invoke-SleepyApi -Endpoint "set" -RequiresAuth -QueryParams @{
        status = $StatusId
    }

    return $response
}

# Function to set device status
function Set-SleepyDeviceStatus {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Id,

        [Parameter(Mandatory = $true)]
        [string]$ShowName,

        [Parameter(Mandatory = $true)]
        [bool]$Using,

        [Parameter(Mandatory = $false)]
        [string]$AppName = ""
    )

    $body = @{
        id = $Id
        show_name = $ShowName
        using = $Using
        app_name = $AppName
    }

    $response = Invoke-SleepyApi -Endpoint "device/set" -Method "POST" -Body $body -RequiresAuth
    return $response
}

# Function to remove device
function Remove-SleepyDevice {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Id
    )

    $response = Invoke-SleepyApi -Endpoint "device/remove" -RequiresAuth -QueryParams @{
        id = $Id
    }

    return $response
}

# Function to clear all devices
function Clear-SleepyDevices {
    $response = Invoke-SleepyApi -Endpoint "device/clear" -RequiresAuth
    return $response
}

# Function to toggle private mode
function Set-SleepyPrivateMode {
    param (
        [Parameter(Mandatory = $true)]
        [bool]$Private
    )

    $response = Invoke-SleepyApi -Endpoint "device/private_mode" -RequiresAuth -QueryParams @{
        private = $Private.ToString().ToLower()
    }

    return $response
}

# Function to save data
function Save-SleepyData {
    $response = Invoke-SleepyApi -Endpoint "save_data" -RequiresAuth
    return $response
}

# Function to display current status
function Show-CurrentStatus {
    Clear-Host
    Write-Host "=== Sleepy Control Panel - Current Status ===" -ForegroundColor Cyan

    $status = Get-SleepyStatus
    if ($null -eq $status) {
        Write-Host "Failed to retrieve status information." -ForegroundColor Red
        return
    }

    Write-Host ""
    Write-Host "Time: $($status.time) ($($status.timezone))" -ForegroundColor Yellow
    Write-Host "Status: $($status.info.name) ($($status.status))" -ForegroundColor Yellow
    Write-Host "Description: $($status.info.color)" -ForegroundColor Yellow
    Write-Host "Last Updated: $($status.last_updated)" -ForegroundColor Yellow

    Write-Host ""
    Write-Host "Devices:" -ForegroundColor Yellow
    if ($status.device.PSObject.Properties.Count -eq 0) {
        Write-Host "  No devices or private mode enabled" -ForegroundColor Gray
    }
    else {
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

    Write-Host ""
    # Always wait for user input in this function, but use our helper to handle full debug mode differently
    if ($script:Config.FullDebugMode) {
        Wait-ForUserInput -Message "Press any key to return to the main menu (full debug mode)..."
    } else {
        Write-Host "Press any key to return to the main menu..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

# Function to change status
function Change-Status {
    Clear-Host
    Write-Host "=== Sleepy Control Panel - Change Status ===" -ForegroundColor Cyan

    $statusList = Get-SleepyStatusList
    if ($null -eq $statusList) {
        Write-Host "Failed to retrieve status list." -ForegroundColor Red
        return
    }

    Write-Host ""
    Write-Host "Available Statuses:" -ForegroundColor Yellow
    foreach ($status in $statusList) {
        Write-Host "  $($status.id): $($status.name) - $($status.desc)" -ForegroundColor Gray
    }

    Write-Host ""
    $statusId = Read-Host "Enter status ID to set (or press Enter to cancel)"

    if ([string]::IsNullOrEmpty($statusId)) {
        return
    }

    if (-not [int]::TryParse($statusId, [ref]$null)) {
        Write-Host "Invalid status ID. Please enter a number." -ForegroundColor Red
        Start-Sleep -Seconds 2
        return
    }

    $response = Set-SleepyStatus -StatusId $statusId
    if ($null -ne $response -and $response.success) {
        Write-Host "Status changed successfully to $statusId." -ForegroundColor Green
    }
    else {
        Write-Host "Failed to change status." -ForegroundColor Red
    }

    # Use our helper function to handle waiting
    Wait-ForUserInput -Message "Press any key to continue (full debug mode)..."
}

# Function to manage devices
function Manage-Devices {
    $menuItems = @(
        "Add/Update Device",
        "Remove Device",
        "Clear All Devices",
        "Toggle Private Mode",
        "Return to Main Menu"
    )

    $selection = 0

    while ($true) {
        Clear-Host
        Write-Host "=== Sleepy Control Panel - Device Management ===" -ForegroundColor Cyan

        for ($i = 0; $i -lt $menuItems.Count; $i++) {
            if ($i -eq $selection) {
                Write-Host "→ $($menuItems[$i])" -ForegroundColor Green
            }
            else {
                Write-Host "  $($menuItems[$i])" -ForegroundColor Gray
            }
        }

        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

        switch ($key.VirtualKeyCode) {
            38 { # Up arrow
                if ($selection -gt 0) {
                    $selection--
                }
            }
            40 { # Down arrow
                if ($selection -lt $menuItems.Count - 1) {
                    $selection++
                }
            }
            13 { # Enter
                switch ($selection) {
                    0 { Add-UpdateDevice }
                    1 { Remove-Device }
                    2 { Clear-Devices }
                    3 { Toggle-PrivateMode }
                    4 { return }
                }
            }
        }
    }
}

# Function to add or update a device
function Add-UpdateDevice {
    Clear-Host
    Write-Host "=== Sleepy Control Panel - Add/Update Device ===" -ForegroundColor Cyan

    Write-Host ""
    $id = Read-Host "Enter device ID (e.g., device-1)"
    $showName = Read-Host "Enter display name"

    $usingInput = Read-Host "Is the device in use? (y/n)"
    $using = $usingInput.ToLower() -eq "y"

    $appName = ""
    if ($using) {
        $appName = Read-Host "Enter application name"
    }

    $response = Set-SleepyDeviceStatus -Id $id -ShowName $showName -Using $using -AppName $appName

    if ($null -ne $response -and $response.success) {
        Write-Host "Device updated successfully." -ForegroundColor Green
    }
    else {
        Write-Host "Failed to update device." -ForegroundColor Red
    }

    # Use our helper function to handle waiting
    Wait-ForUserInput -Message "Press any key to continue (full debug mode)..."
}

# Function to remove a device
function Remove-Device {
    Clear-Host
    Write-Host "=== Sleepy Control Panel - Remove Device ===" -ForegroundColor Cyan

    $status = Get-SleepyStatus
    if ($null -eq $status) {
        Write-Host "Failed to retrieve status information." -ForegroundColor Red
        Wait-ForUserInput -Message "Press any key to continue (full debug mode)..."
        return
    }

    Write-Host ""
    Write-Host "Current Devices:" -ForegroundColor Yellow
    if ($status.device.PSObject.Properties.Count -eq 0) {
        Write-Host "  No devices or private mode enabled" -ForegroundColor Gray
        Wait-ForUserInput -Message "Press any key to continue (full debug mode)..."
        return
    }

    foreach ($deviceProp in $status.device.PSObject.Properties) {
        $device = $deviceProp.Value
        $deviceId = $deviceProp.Name

        Write-Host "  $($device.show_name) ($deviceId)" -ForegroundColor Gray
    }

    Write-Host ""
    $id = Read-Host "Enter device ID to remove (or press Enter to cancel)"

    if ([string]::IsNullOrEmpty($id)) {
        return
    }

    $response = Remove-SleepyDevice -Id $id

    if ($null -ne $response -and $response.success) {
        Write-Host "Device removed successfully." -ForegroundColor Green
    }
    else {
        Write-Host "Failed to remove device." -ForegroundColor Red
    }

    # Use our helper function to handle waiting
    Wait-ForUserInput -Message "Press any key to continue (full debug mode)..."
}

# Function to clear all devices
function Clear-Devices {
    Clear-Host
    Write-Host "=== Sleepy Control Panel - Clear All Devices ===" -ForegroundColor Cyan

    Write-Host ""
    $confirm = Read-Host "Are you sure you want to clear all devices? (y/n)"

    if ($confirm.ToLower() -ne "y") {
        return
    }

    $response = Clear-SleepyDevices

    if ($null -ne $response -and $response.success) {
        Write-Host "All devices cleared successfully." -ForegroundColor Green
    }
    else {
        Write-Host "Failed to clear devices." -ForegroundColor Red
    }

    # Use our helper function to handle waiting
    Wait-ForUserInput -Message "Press any key to continue (full debug mode)..."
}

# Function to toggle private mode
function Toggle-PrivateMode {
    Clear-Host
    Write-Host "=== Sleepy Control Panel - Toggle Private Mode ===" -ForegroundColor Cyan

    Write-Host ""
    $enableInput = Read-Host "Enable private mode? (y/n)"
    $enable = $enableInput.ToLower() -eq "y"

    $response = Set-SleepyPrivateMode -Private $enable

    if ($null -ne $response -and $response.success) {
        $modeText = if ($enable) { "enabled" } else { "disabled" }
        Write-Host "Private mode $modeText successfully." -ForegroundColor Green
    }
    else {
        Write-Host "Failed to toggle private mode." -ForegroundColor Red
    }

    # Use our helper function to handle waiting
    Wait-ForUserInput -Message "Press any key to continue (full debug mode)..."
}

# Function to save data
function Save-Data {
    Clear-Host
    Write-Host "=== Sleepy Control Panel - Save Data ===" -ForegroundColor Cyan

    Write-Host ""
    $response = Save-SleepyData

    if ($null -ne $response -and $response.success) {
        Write-Host "Data saved successfully." -ForegroundColor Green
    }
    else {
        Write-Host "Failed to save data." -ForegroundColor Red
    }

    # Use our helper function to handle waiting
    Wait-ForUserInput -Message "Press any key to continue (full debug mode)..."
}

# Function to configure settings
function Configure-Settings {
    Clear-Host
    Write-Host "=== Sleepy Control Panel - Settings ===" -ForegroundColor Cyan

    Write-Host ""
    Write-Host "Current Settings:" -ForegroundColor Yellow
    Write-Host "  API URL: $($script:Config.ApiUrl)" -ForegroundColor Gray
    Write-Host "  Secret: $(if ([string]::IsNullOrEmpty($script:Config.Secret)) { "<Not Set>" } else { "********" })" -ForegroundColor Gray
    Write-Host "  Refresh Interval: $($script:Config.RefreshInterval) seconds" -ForegroundColor Gray
    Write-Host "  Debug Mode: $(if ($script:Config.DebugMode) { "Enabled" } else { "Disabled" })" -ForegroundColor Gray
    Write-Host "  Full Debug Mode: $(if ($script:Config.FullDebugMode) { "Enabled" } else { "Disabled" })" -ForegroundColor Gray

    Write-Host ""
    $newApiUrl = Read-Host "Enter new API URL (or press Enter to keep current)"
    if (-not [string]::IsNullOrEmpty($newApiUrl)) {
        $script:Config.ApiUrl = $newApiUrl
    }

    $newSecret = Read-Host "Enter new secret (or press Enter to keep current)"
    if (-not [string]::IsNullOrEmpty($newSecret)) {
        $script:Config.Secret = $newSecret
    }

    $newRefreshInterval = Read-Host "Enter new refresh interval in seconds (or press Enter to keep current)"
    if (-not [string]::IsNullOrEmpty($newRefreshInterval) -and [int]::TryParse($newRefreshInterval, [ref]$null)) {
        $script:Config.RefreshInterval = [int]$newRefreshInterval
    }

    $debugModeInput = Read-Host "Enable debug mode? (y/n) (or press Enter to keep current)"
    if (-not [string]::IsNullOrEmpty($debugModeInput)) {
        $script:Config.DebugMode = $debugModeInput.ToLower() -eq "y"

        # If debug mode is disabled, also disable full debug mode
        if (-not $script:Config.DebugMode) {
            $script:Config.FullDebugMode = $false
        }
    }

    # Only show full debug mode option if debug mode is enabled
    if ($script:Config.DebugMode) {
        $fullDebugModeInput = Read-Host "Enable full debug mode? (y/n) (or press Enter to keep current)"
        if (-not [string]::IsNullOrEmpty($fullDebugModeInput)) {
            $script:Config.FullDebugMode = $fullDebugModeInput.ToLower() -eq "y"
        }
    }

    Save-Configuration

    Write-Host ""
    Write-Host "Settings updated successfully." -ForegroundColor Green

    # Use our helper function to handle waiting
    Wait-ForUserInput -Message "Press any key to continue (full debug mode)..."
}

# Main menu function
function Show-MainMenu {
    $menuItems = @(
        "View Current Status",
        "Change Status",
        "Manage Devices",
        "Save Data",
        "Settings",
        "Exit"
    )

    $selection = 0

    while ($true) {
        Clear-Host
        Write-Host "=== Sleepy Control Panel ===" -ForegroundColor Cyan
        Write-Host "API URL: $($script:Config.ApiUrl)" -ForegroundColor DarkGray

        for ($i = 0; $i -lt $menuItems.Count; $i++) {
            if ($i -eq $selection) {
                Write-Host "→ $($menuItems[$i])" -ForegroundColor Green
            }
            else {
                Write-Host "  $($menuItems[$i])" -ForegroundColor Gray
            }
        }

        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

        switch ($key.VirtualKeyCode) {
            38 { # Up arrow
                if ($selection -gt 0) {
                    $selection--
                }
            }
            40 { # Down arrow
                if ($selection -lt $menuItems.Count - 1) {
                    $selection++
                }
            }
            13 { # Enter
                switch ($selection) {
                    0 { Show-CurrentStatus }
                    1 { Change-Status }
                    2 { Manage-Devices }
                    3 { Save-Data }
                    4 { Configure-Settings }
                    5 { return }
                }
            }
        }
    }
}

# Main script execution
function Start-SleepyControlPanel {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch]$DebugMode,

        [Parameter(Mandatory = $false)]
        [switch]$FullDebugMode
    )

    # Add System.Web assembly for query string handling
    Add-Type -AssemblyName System.Web

    # Load configuration
    Load-Configuration

    # Apply command-line parameters
    if ($DebugMode) {
        $script:Config.DebugMode = $true
        Write-Host "Debug mode enabled from command line." -ForegroundColor Yellow
    }

    if ($FullDebugMode) {
        $script:Config.DebugMode = $true
        $script:Config.FullDebugMode = $true
        Write-Host "Full debug mode enabled from command line." -ForegroundColor Yellow
    }

    # Show main menu
    Show-MainMenu
}

# Start the control panel
# Pass through any command-line parameters
$scriptParams = @{}
foreach ($param in $PSBoundParameters.GetEnumerator()) {
    $scriptParams[$param.Key] = $param.Value
}
Start-SleepyControlPanel @scriptParams
