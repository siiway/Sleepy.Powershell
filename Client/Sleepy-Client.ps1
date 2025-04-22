#requires -Version 5.1

<#
.SYNOPSIS
    Sleepy Client - A PowerShell-based client for Sleepy API
.DESCRIPTION
    This script runs as a background client that periodically sends "online" status
    to the Sleepy API with the foreground window title as the application name.
    When the script is closed, it sends an "offline" status.
.NOTES
    Author: NT_AUTHORITY
    Version: 1.0
#>

# Configuration
$script:Config = @{
    ApiUrl = "http://localhost:9010"  # Default API URL, can be changed in settings
    Secret = ""                       # Secret for authentication, can be set in settings
    RefreshInterval = 10              # Refresh interval in seconds
    DeviceId = "device-1"    # Device ID to use
    DeviceName = $env:COMPUTERNAME    # Device name to display
    DebugMode = $false                # Debug mode flag, enables detailed logging
}

# Add required assemblies
Add-Type -AssemblyName System.Web
Add-Type @'
using System;
using System.Runtime.InteropServices;
using System.Text;

public class WindowUtils {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);

    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

    public static string GetActiveWindowTitle() {
        const int nChars = 256;
        StringBuilder buff = new StringBuilder(nChars);
        IntPtr handle = GetForegroundWindow();

        if (GetWindowText(handle, buff, nChars) > 0) {
            return buff.ToString();
        }
        return "";
    }

    public static uint GetActiveWindowProcessId() {
        IntPtr handle = GetForegroundWindow();
        uint processId = 0;
        GetWindowThreadProcessId(handle, out processId);
        return processId;
    }
}
'@

# Function to load configuration from file
function Load-Configuration {
    $configPath = Join-Path $PSScriptRoot "sleepy-client-config.json"
    if (Test-Path $configPath) {
        try {
            $loadedConfig = Get-Content $configPath -Raw | ConvertFrom-Json
            $script:Config.ApiUrl = $loadedConfig.ApiUrl
            $script:Config.Secret = $loadedConfig.Secret
            $script:Config.RefreshInterval = $loadedConfig.RefreshInterval
            $script:Config.DeviceId = $loadedConfig.DeviceId
            $script:Config.DeviceName = $loadedConfig.DeviceName
            
            # Load debug mode if it exists in the config file
            if (Get-Member -InputObject $loadedConfig -Name "DebugMode" -MemberType Properties) {
                $script:Config.DebugMode = $loadedConfig.DebugMode
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
    $configPath = Join-Path $PSScriptRoot "sleepy-client-config.json"
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
        [System.ConsoleColor]$ForegroundColor = [System.ConsoleColor]::DarkCyan
    )
    
    if ($script:Config.DebugMode) {
        Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [DEBUG] $Message" -ForegroundColor $ForegroundColor
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
        $headers["Sleepy-Secret"] = $script:Config.Secret
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
        $response = Invoke-RestMethod @params
        
        # Log response in debug mode
        if ($script:Config.DebugMode) {
            $responseJson = $response | ConvertTo-Json -Depth 3
            Write-DebugInfo "Response received: $responseJson" -ForegroundColor DarkGreen
        }
        
        return $response
    }
    catch {
        Write-Host "API request failed: $_" -ForegroundColor Red
        Write-DebugInfo "API request failed with error: $_" -ForegroundColor Red
        
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
            $statusDescription = $_.Exception.Response.StatusDescription
            Write-Host "Status Code: $statusCode - $statusDescription" -ForegroundColor Red
            Write-DebugInfo "HTTP Status: $statusCode - $statusDescription" -ForegroundColor Red
            
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

# Function to get active window information
function Get-ActiveWindowInfo {
    try {
        $windowTitle = [WindowUtils]::GetActiveWindowTitle()
        $processId = [WindowUtils]::GetActiveWindowProcessId()
        
        if ($processId -gt 0) {
            $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
            if ($process) {
                return @{
                    ProcessName = $process.ProcessName
                    WindowTitle = $windowTitle
                    ProcessId = $processId
                }
            }
        }
        
        # Fallback if we couldn't get process info
        return @{
            ProcessName = "Unknown"
            WindowTitle = $windowTitle
            ProcessId = $processId
        }
    }
    catch {
        Write-DebugInfo "Error getting active window info: $_" -ForegroundColor Red
        return @{
            ProcessName = "Error"
            WindowTitle = "Error getting window info"
            ProcessId = 0
        }
    }
}

# Function to configure settings
function Configure-Settings {
    Clear-Host
    Write-Host "=== Sleepy Client - Settings ===" -ForegroundColor Cyan
    
    Write-Host ""
    Write-Host "Current Settings:" -ForegroundColor Yellow
    Write-Host "  API URL: $($script:Config.ApiUrl)" -ForegroundColor Gray
    Write-Host "  Secret: $(if ([string]::IsNullOrEmpty($script:Config.Secret)) { "<Not Set>" } else { "********" })" -ForegroundColor Gray
    Write-Host "  Refresh Interval: $($script:Config.RefreshInterval) seconds" -ForegroundColor Gray
    Write-Host "  Device ID: $($script:Config.DeviceId)" -ForegroundColor Gray
    Write-Host "  Device Name: $($script:Config.DeviceName)" -ForegroundColor Gray
    Write-Host "  Debug Mode: $(if ($script:Config.DebugMode) { "Enabled" } else { "Disabled" })" -ForegroundColor Gray
    
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
    
    $newDeviceId = Read-Host "Enter new device ID (or press Enter to keep current)"
    if (-not [string]::IsNullOrEmpty($newDeviceId)) {
        $script:Config.DeviceId = $newDeviceId
    }
    
    $newDeviceName = Read-Host "Enter new device name (or press Enter to keep current)"
    if (-not [string]::IsNullOrEmpty($newDeviceName)) {
        $script:Config.DeviceName = $newDeviceName
    }
    
    $debugModeInput = Read-Host "Enable debug mode? (y/n) (or press Enter to keep current)"
    if (-not [string]::IsNullOrEmpty($debugModeInput)) {
        $script:Config.DebugMode = $debugModeInput.ToLower() -eq "y"
    }
    
    Save-Configuration
    
    Write-Host ""
    Write-Host "Settings updated successfully." -ForegroundColor Green
    Start-Sleep -Seconds 2
}

# Function to display status information
function Show-StatusInfo {
    param (
        [Parameter(Mandatory = $true)]
        [object]$Status,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$WindowInfo
    )
    
    Clear-Host
    Write-Host "=== Sleepy Client - Running ===" -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to exit" -ForegroundColor DarkGray
    
    Write-Host ""
    Write-Host "Server Status:" -ForegroundColor Yellow
    Write-Host "  Time: $($Status.time) ($($Status.timezone))" -ForegroundColor Gray
    Write-Host "  Status: $($Status.info.name) ($($Status.status))" -ForegroundColor Gray
    Write-Host "  Last Updated: $($Status.last_updated)" -ForegroundColor Gray
    
    Write-Host ""
    Write-Host "Client Status:" -ForegroundColor Yellow
    Write-Host "  Device ID: $($script:Config.DeviceId)" -ForegroundColor Gray
    Write-Host "  Device Name: $($script:Config.DeviceName)" -ForegroundColor Gray
    Write-Host "  Current Window: $($WindowInfo.WindowTitle)" -ForegroundColor Gray
    Write-Host "  Process: $($WindowInfo.ProcessName) (PID: $($WindowInfo.ProcessId))" -ForegroundColor Gray
    Write-Host "  Refresh Interval: $($script:Config.RefreshInterval) seconds" -ForegroundColor Gray
    Write-Host "  Next Update: $(Get-Date).AddSeconds($script:Config.RefreshInterval)" -ForegroundColor Gray
    
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Yellow
    Write-Host "  S - Settings" -ForegroundColor Gray
    Write-Host "  R - Refresh Now" -ForegroundColor Gray
    Write-Host "  Q - Quit" -ForegroundColor Gray
}

# Function to send "offline" status when script is closed
function Send-OfflineStatus {
    Write-Host "Sending offline status..." -ForegroundColor Yellow
    
    $response = Set-SleepyDeviceStatus -Id $script:Config.DeviceId -ShowName $script:Config.DeviceName -Using $false -AppName ""
    
    if ($null -ne $response -and $response.success) {
        Write-Host "Offline status sent successfully." -ForegroundColor Green
    }
    else {
        Write-Host "Failed to send offline status." -ForegroundColor Red
    }
}

# Register script exit handler
$OnExitScript = {
    Send-OfflineStatus
}
Register-EngineEvent -SourceIdentifier ([System.Management.Automation.PsEngineEvent]::Exiting) -Action $OnExitScript | Out-Null

# Main client function
function Start-SleepyClient {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch]$DebugMode
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
    
    # Check if configuration is valid
    if ([string]::IsNullOrEmpty($script:Config.ApiUrl)) {
        Write-Host "API URL is not configured. Please configure settings first." -ForegroundColor Red
        Configure-Settings
    }
    
    if ([string]::IsNullOrEmpty($script:Config.Secret)) {
        Write-Host "Secret is not configured. Please configure settings first." -ForegroundColor Red
        Configure-Settings
    }
    
    # Main loop
    $lastWindowTitle = ""
    $lastUpdateTime = [DateTime]::MinValue
    
    try {
        while ($true) {
            # Get current status
            $status = Get-SleepyStatus
            
            # Get active window information
            $windowInfo = Get-ActiveWindowInfo
            
            # Display status information
            Show-StatusInfo -Status $status -WindowInfo $windowInfo
            
            # Check if window title has changed or update interval has passed
            $currentTime = Get-Date
            if ($windowInfo.WindowTitle -ne $lastWindowTitle -or $currentTime -ge $lastUpdateTime.AddSeconds($script:Config.RefreshInterval)) {
                # Send online status with current window title
                $appName = if ([string]::IsNullOrEmpty($windowInfo.WindowTitle)) { $windowInfo.ProcessName } else { $windowInfo.WindowTitle }
                
                Write-Host "Sending online status with app: $appName" -ForegroundColor Yellow
                
                $response = Set-SleepyDeviceStatus -Id $script:Config.DeviceId -ShowName $script:Config.DeviceName -Using $true -AppName $appName
                
                if ($null -ne $response -and $response.success) {
                    Write-Host "Online status sent successfully." -ForegroundColor Green
                    $lastWindowTitle = $windowInfo.WindowTitle
                    $lastUpdateTime = $currentTime
                }
                else {
                    Write-Host "Failed to send online status." -ForegroundColor Red
                }
            }
            
            # Check for user input (non-blocking)
            if ($host.UI.RawUI.KeyAvailable) {
                $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                
                switch ($key.Character.ToString().ToLower()) {
                    "s" { 
                        Configure-Settings
                        break
                    }
                    "r" { 
                        Write-Host "Forcing refresh..." -ForegroundColor Yellow
                        $lastWindowTitle = ""  # Force update
                        break
                    }
                    "q" { 
                        Write-Host "Exiting..." -ForegroundColor Yellow
                        Send-OfflineStatus
                        exit
                    }
                }
            }
            
            # Wait a short time before checking again
            Start-Sleep -Milliseconds 500
        }
    }
    finally {
        # Ensure we send offline status when exiting
        Send-OfflineStatus
    }
}

# Start the client
Start-SleepyClient @args
