# Sleepy PowerShell Client

[中文简体](Client/README_zh.md) | [English](Client/README.md)

A PowerShell-based client for the Sleepy API that runs in the background and periodically sends "online" status with the foreground window title as the application name. When the script is closed, it automatically sends an "offline" status.

## Features

- Runs as a background client with a simple TUI (Text User Interface)
- Automatically detects the active window title and sends it as the application name
- Periodically updates status based on a configurable refresh interval
- Sends "offline" status when the script is closed
- Configurable device ID and name
- Debug mode for troubleshooting

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
   .\Sleepy-Client.ps1
   ```

   You can also enable debug mode directly from the command line:
   ```powershell
   # Enable debug mode
   .\Sleepy-Client.ps1 -DebugMode
   ```

2. On first run, you'll be prompted to configure:
   - API URL (default: http://localhost:9010)
   - Secret for authentication
   - Refresh interval
   - Device ID and name

3. The client will display a simple TUI with:
   - Server status information
   - Client status information
   - Current active window information
   - Available commands

4. Available commands:
   - S - Open settings
   - R - Force refresh now
   - Q - Quit (sends offline status)

## Configuration

The client stores its configuration in a `sleepy-client-config.json` file in the same directory as the script. This file contains:

- `ApiUrl`: The URL of the Sleepy API server
- `Secret`: The authentication secret for the API (used in standard Bearer token authentication)
- `RefreshInterval`: How often to refresh status information (in seconds)
- `DeviceId`: The device ID to use when sending status updates
- `DeviceName`: The device name to display
- `DebugMode`: When enabled, outputs detailed logging information

## How It Works

1. The client periodically checks the active window title using Windows API calls
2. When the active window changes or the refresh interval passes, it sends an update to the Sleepy API
3. The update includes:
   - Device ID and name
   - "Using" status set to true
   - Application name set to the active window title
4. When the script is closed (either by pressing Q or using Ctrl+C), it sends an "offline" status

## License

This project is open source and available under the GNU GPL v3 License.
