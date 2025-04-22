# Sleepy PowerShell SDK

A PowerShell SDK for interacting with the Sleepy API. This SDK provides a simple and intuitive way to integrate Sleepy functionality into your PowerShell scripts and applications.

## Features

- Complete API coverage for Sleepy functionality
- Configurable debug modes for troubleshooting
- Automatic authentication handling
- Query parameter support
- Comprehensive error handling
- Verbose logging options

## Requirements

- PowerShell 5.1 or higher
- Access to a running Sleepy API server

## Installation

1. Clone or download this repository
2. Import the module in your PowerShell script:
   ```powershell
   Import-Module -Name "path\to\SDK\Sleepy.psm1"
   ```

## Quick Start

```powershell
# Import the module
Import-Module -Name ".\Sleepy.psm1"

# Configure the SDK
Set-SleepyConfig -ApiUrl "http://localhost:9010" -Secret "YourSecretHere"

# Get current status
$status = Get-SleepyStatus

# Set a new status
Set-SleepyStatus -StatusId 0

# Update device status
Set-SleepyDeviceStatus -Id "device-1" -ShowName "My Device" -Using $true -AppName "PowerShell"
```

## Available Functions

- `Import-SleepyConfig`: Load configuration from file
- `Set-SleepyConfig`: Configure SDK settings
- `Get-SleepyStatus`: Get current status
- `Get-SleepyStatusList`: Get available status options
- `Set-SleepyStatus`: Set current status
- `Set-SleepyDeviceStatus`: Update device status
- `Remove-SleepyDevice`: Remove a device
- `Clear-SleepyDevices`: Remove all devices
- `Set-SleepyPrivateMode`: Toggle private mode
- `Save-SleepyData`: Save current state to persistent storage

## Debug Modes

The SDK supports two debug levels:

1. Basic Debug Mode:
```powershell
Set-SleepyConfig -DebugMode
```

2. Full Debug Mode (includes complete request/response details):
```powershell
Set-SleepyConfig -FullDebugMode
```

## Configuration

The SDK can be configured using a JSON file (`sleepy-config.json`) or programmatically:

```json
{
    "ApiUrl": "http://localhost:9010",
    "Secret": "YourSecretHere",
    "DebugMode": false,
    "FullDebugMode": false
}
```

## Example Usage

See `Example-Usage.ps1` for comprehensive examples of all SDK functionality.

## Error Handling

The SDK includes robust error handling with detailed error messages and debug information. In debug modes, you'll receive comprehensive information about any failures, including:

- HTTP status codes
- Error messages
- Stack traces
- Request/response details

## License

This project is open source and available under the GNU GPL v3 License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
