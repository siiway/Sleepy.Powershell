#requires -Version 5.1

<#
.SYNOPSIS
    Sleepy API Module - PowerShell module for interacting with the Sleepy API
.DESCRIPTION
    This module provides functions to interact with the Sleepy API programmatically.
.NOTES
    Author: Augment Agent
    Version: 1.0
#>

# Configuration
$script:Config = @{
    ApiUrl = "http://localhost:9010"  # Default API URL
    Secret = ""                       # Secret for authentication
    DebugMode = $false                # Debug mode flag, enables detailed logging
    FullDebugMode = $false            # Full debug mode flag, enables complete request/response logging
}

# Function to load configuration from file
function Import-SleepyConfig {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$ConfigPath = (Join-Path $PSScriptRoot "sleepy-config.json")
    )

    if (Test-Path $ConfigPath) {
        try {
            $loadedConfig = Get-Content $ConfigPath -Raw | ConvertFrom-Json
            $script:Config.ApiUrl = $loadedConfig.ApiUrl
            $script:Config.Secret = $loadedConfig.Secret

            # Load debug mode if it exists in the config file
            if (Get-Member -InputObject $loadedConfig -Name "DebugMode" -MemberType Properties) {
                $script:Config.DebugMode = $loadedConfig.DebugMode
            }

            # Load full debug mode if it exists in the config file
            if (Get-Member -InputObject $loadedConfig -Name "FullDebugMode" -MemberType Properties) {
                $script:Config.FullDebugMode = $loadedConfig.FullDebugMode
            }
            Write-Verbose "Configuration loaded successfully from $ConfigPath."
            return $true
        }
        catch {
            Write-Error "Error loading configuration: $_"
            return $false
        }
    }
    else {
        Write-Warning "Configuration file not found at $ConfigPath."
        return $false
    }
}

# Function to set configuration
function Set-SleepyConfig {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$ApiUrl,

        [Parameter(Mandatory = $false)]
        [string]$Secret,

        [Parameter(Mandatory = $false)]
        [switch]$DebugMode,

        [Parameter(Mandatory = $false)]
        [switch]$FullDebugMode
    )

    if (-not [string]::IsNullOrEmpty($ApiUrl)) {
        $script:Config.ApiUrl = $ApiUrl
    }

    if (-not [string]::IsNullOrEmpty($Secret)) {
        $script:Config.Secret = $Secret
    }

    if ($PSBoundParameters.ContainsKey('DebugMode')) {
        $script:Config.DebugMode = $DebugMode.IsPresent

        # If debug mode is disabled, also disable full debug mode
        if (-not $script:Config.DebugMode) {
            $script:Config.FullDebugMode = $false
        }
    }

    if ($PSBoundParameters.ContainsKey('FullDebugMode')) {
        # If full debug mode is enabled, also enable debug mode
        if ($FullDebugMode.IsPresent) {
            $script:Config.DebugMode = $true
        }
        $script:Config.FullDebugMode = $FullDebugMode.IsPresent
    }

    Write-Verbose "Configuration updated."
}

# Function to write debug information
function Write-SleepyDebug {
    [CmdletBinding()]
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
            Write-Verbose "[DEBUG] $Message" -Verbose
        }
    }
}

# Helper function to make API requests
function Invoke-SleepyApi {
    [CmdletBinding()]
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
    Write-SleepyDebug "API Request: $Method $uri"

    # Add authentication if required
    $headers = @{}
    if ($RequiresAuth) {
        if ([string]::IsNullOrEmpty($script:Config.Secret)) {
            Write-Error "Authentication required but no secret is configured."
            return $null
        }
        $BearerToken = "Bearer $($script:Config.Secret)"
        $headers["Authorization"] = $BearerToken
        Write-SleepyDebug "Added authentication header"
    }

    # Add query parameters
    if ($QueryParams.Count -gt 0) {
        $queryString = [System.Web.HttpUtility]::ParseQueryString([string]::Empty)
        foreach ($key in $QueryParams.Keys) {
            $queryString.Add($key, $QueryParams[$key])
            Write-SleepyDebug "Added query parameter: $key = $($QueryParams[$key])"
        }
        $uriBuilder = New-Object System.UriBuilder($uri)
        $uriBuilder.Query = $queryString.ToString()
        $uri = $uriBuilder.Uri.ToString()
        Write-SleepyDebug "Final URI with query parameters: $uri"
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
            Write-SleepyDebug "Request body: $bodyJson"
        }
    }

    try {
        Write-SleepyDebug "Sending request to $uri"

        # Log full request details in full debug mode
        if ($script:Config.FullDebugMode) {
            Write-SleepyDebug "Full request details:" -FullDebugOnly
            Write-SleepyDebug "  Method: $Method" -FullDebugOnly
            Write-SleepyDebug "  URI: $uri" -FullDebugOnly
            Write-SleepyDebug "  Headers: $(ConvertTo-Json -InputObject $headers -Compress)" -FullDebugOnly

            if ($params.ContainsKey('Body')) {
                Write-SleepyDebug "  Body: $($params.Body)" -FullDebugOnly
            }
            else {
                Write-SleepyDebug "  Body: None" -FullDebugOnly
            }

            Write-SleepyDebug "  ContentType: $($params.ContentType)" -FullDebugOnly
            Write-SleepyDebug "  ErrorAction: $($params.ErrorAction)" -FullDebugOnly
        }

        $response = Invoke-RestMethod @params

        # Log response in debug mode
        if ($script:Config.DebugMode) {
            $responseJson = $response | ConvertTo-Json -Depth 3
            Write-SleepyDebug "Response received: $responseJson"

            # Log full response details in full debug mode
            if ($script:Config.FullDebugMode) {
                Write-SleepyDebug "Full response details:" -FullDebugOnly
                Write-SleepyDebug "  StatusCode: 200 (OK)" -FullDebugOnly
                Write-SleepyDebug "  Content: $responseJson" -FullDebugOnly
            }
        }

        return $response
    }
    catch {
        Write-Error "API request failed: $_"
        Write-SleepyDebug "API request failed with error: $_"

        # Log full exception details in full debug mode
        if ($script:Config.FullDebugMode) {
            Write-SleepyDebug "Full exception details:" -FullDebugOnly
            Write-SleepyDebug "  Exception Type: $($_.Exception.GetType().FullName)" -FullDebugOnly
            Write-SleepyDebug "  Message: $($_.Exception.Message)" -FullDebugOnly
            Write-SleepyDebug "  StackTrace: $($_.Exception.StackTrace)" -FullDebugOnly

            if ($_.InvocationInfo) {
                Write-SleepyDebug "  ScriptName: $($_.InvocationInfo.ScriptName)" -FullDebugOnly
                Write-SleepyDebug "  Line: $($_.InvocationInfo.ScriptLineNumber)" -FullDebugOnly
                Write-SleepyDebug "  Position: $($_.InvocationInfo.OffsetInLine)" -FullDebugOnly
                Write-SleepyDebug "  Line Content: $($_.InvocationInfo.Line)" -FullDebugOnly
            }
        }

        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
            $statusDescription = $_.Exception.Response.StatusDescription
            Write-Error "Status Code: $statusCode - $statusDescription"
            Write-SleepyDebug "HTTP Status: $statusCode - $statusDescription"

            # Log full response details in full debug mode
            if ($script:Config.FullDebugMode) {
                Write-SleepyDebug "Full response details:" -FullDebugOnly
                Write-SleepyDebug "  StatusCode: $statusCode" -FullDebugOnly
                Write-SleepyDebug "  StatusDescription: $statusDescription" -FullDebugOnly
                Write-SleepyDebug "  ResponseUri: $($_.Exception.Response.ResponseUri)" -FullDebugOnly
                Write-SleepyDebug "  Server: $($_.Exception.Response.Server)" -FullDebugOnly
                Write-SleepyDebug "  ContentType: $($_.Exception.Response.ContentType)" -FullDebugOnly
                Write-SleepyDebug "  ContentLength: $($_.Exception.Response.ContentLength)" -FullDebugOnly
            }

            try {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $responseBody = $reader.ReadToEnd()
                Write-Error "Response: $responseBody"
                Write-SleepyDebug "Error response body: $responseBody"
            }
            catch {
                Write-Error "Could not read response body."
                Write-SleepyDebug "Failed to read error response body: $_"
            }
        }
        return $null
    }
}

# Function to get current status
function Get-SleepyStatus {
    [CmdletBinding()]
    param()

    $response = Invoke-SleepyApi -Endpoint "query"
    return $response
}

# Function to get available status list
function Get-SleepyStatusList {
    [CmdletBinding()]
    param()

    $response = Invoke-SleepyApi -Endpoint "status_list"
    return $response
}

# Function to set status
function Set-SleepyStatus {
    [CmdletBinding()]
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
    [CmdletBinding()]
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
    [CmdletBinding()]
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
    [CmdletBinding()]
    param()

    $response = Invoke-SleepyApi -Endpoint "device/clear" -RequiresAuth
    return $response
}

# Function to toggle private mode
function Set-SleepyPrivateMode {
    [CmdletBinding()]
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
    [CmdletBinding()]
    param()

    $response = Invoke-SleepyApi -Endpoint "save_data" -RequiresAuth
    return $response
}

# Add System.Web assembly for query string handling
Add-Type -AssemblyName System.Web

# Export functions
Export-ModuleMember -Function @(
    'Import-SleepyConfig',
    'Set-SleepyConfig',
    'Get-SleepyStatus',
    'Get-SleepyStatusList',
    'Set-SleepyStatus',
    'Set-SleepyDeviceStatus',
    'Remove-SleepyDevice',
    'Clear-SleepyDevices',
    'Set-SleepyPrivateMode',
    'Save-SleepyData'
)
