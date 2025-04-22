# Sleepy PowerShell Control Panel

[中文简体](README_zh.md) | [English](README.md)

A PowerShell-based control panel for managing the Sleepy API. This control panel provides a user-friendly interface to interact with Sleepy, allowing you to manage your status, devices, and other settings.

## Features

- View current status information
- Change your status from available options
- Manage device information:
  - Add/update devices
  - Remove devices
  - Clear all devices
  - Toggle private mode
- Save data to persistent storage
- Configure connection settings
- Debug mode for detailed logging
- Full debug mode for complete request/response information with manual continuation

## Requirements

- PowerShell 5.1 or higher
- Access to a running Sleepy API server

## Installation

1. Clone or download this repository
2. Ensure PowerShell execution policy allows running scripts
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

## Usage

1. Run the script from PowerShell:
   ```powershell
   .\Sleepy-ControlPanel.ps1
   ```

   You can also enable debug modes directly from the command line:
   ```powershell
   # Enable debug mode
   .\Sleepy-ControlPanel.ps1 -DebugMode

   # Enable full debug mode (includes complete request/response details and pauses for review)
   .\Sleepy-ControlPanel.ps1 -FullDebugMode
   ```

2. On first run, go to "Settings" to configure:
   - API URL (default: http://localhost:9010)
   - Secret for authentication
   - Refresh interval

3. Navigate the menu using arrow keys and Enter to select options

## Configuration

The control panel stores its configuration in a `sleepy-config.json` file in the same directory as the script. This file contains:

- `ApiUrl`: The URL of the Sleepy API server
- `Secret`: The authentication secret for the API (used in standard Bearer token authentication)
- `RefreshInterval`: How often to refresh status information (in seconds)
- `DebugMode`: When enabled, outputs detailed logging information about API requests and responses
- `FullDebugMode`: When enabled, outputs complete request and response details, including headers, body content, and exception information. Also pauses after each operation to allow reviewing the debug information before continuing

## Menu Options

### View Current Status
Displays the current status information from the Sleepy API, including:
- Current time and timezone
- Current status and description
- List of devices and their status

### Change Status
Shows a list of available statuses and allows you to select one to set as your current status.

### Manage Devices
Provides a submenu for device management:
- Add/Update Device: Add a new device or update an existing one
- Remove Device: Remove a specific device
- Clear All Devices: Remove all devices
- Toggle Private Mode: Enable or disable private mode

### Save Data
Saves the current status and device information to persistent storage on the server.

### Settings
Configure the control panel settings:
- API URL
- Authentication secret
- Refresh interval
- Debug mode (enable/disable detailed logging)
- Full debug mode (enable/disable complete request/response logging)

## License

This project is open source and available under the GNU GPL v3 License.