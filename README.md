# Sleepy PowerShell Tools

A comprehensive suite of PowerShell tools for interacting with the Sleepy API. This project includes an SDK, background client, and control panel for managing your Sleepy presence.

## Components

### 1. SDK (`/SDK`)
A PowerShell module providing programmatic access to the Sleepy API. Features include:
- Complete API coverage
- Configurable debug modes
- Automatic authentication
- Comprehensive error handling
- Detailed logging options

### 2. Client (`/Client`)
A background client that automatically updates your status based on active windows:
- Runs in the background with a simple TUI
- Automatically detects active window titles
- Periodic status updates
- Automatic offline status on exit
- Configurable refresh intervals

### 3. Control Panel (`/ControlPanel`)
A user-friendly interface for managing Sleepy settings and status:
- Status management
- Device management
- Configuration settings
- Debug options
- Data persistence controls

## Requirements

- PowerShell 5.1 or higher
- Access to a running Sleepy API server
- Windows operating system (for Client window detection features)

## Quick Start

1. Clone this repository:
   ```powershell
   git clone https://github.com/yourusername/sleepy-powershell.git
   ```

2. Ensure PowerShell execution policy allows running scripts:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. Choose your tool:

   **Using the SDK:**
   ```powershell
   Import-Module -Name ".\SDK\Sleepy.psm1"
   Set-SleepyConfig -ApiUrl "http://localhost:8080" -Secret "YourSecretHere"
   ```

   **Running the Client:**
   ```powershell
   .\Client\Sleepy-Client.ps1
   ```

   **Launching the Control Panel:**
   ```powershell
   .\ControlPanel\Sleepy-ControlPanel.ps1
   ```

## Configuration

Each component stores its configuration in a JSON file:

- SDK: `SDK\sleepy-config.json`
- Client: `Client\sleepy-client-config.json`
- Control Panel: `ControlPanel\sleepy-config.json`

Default configuration:
```json
{
    "ApiUrl": "http://localhost:8080",
    "Secret": "YourSecretHere",
    "DebugMode": false,
    "FullDebugMode": false,
    "RefreshInterval": 5
}
```

## Debug Modes

All components support two debug levels:

1. Basic Debug Mode: Shows basic request/response information
2. Full Debug Mode: Shows complete request/response details

Enable debug modes via command line:
```powershell
# For Client
.\Client\Sleepy-Client.ps1 -DebugMode

# For Control Panel
.\ControlPanel\Sleepy-ControlPanel.ps1 -FullDebugMode
```

## Component Documentation

Each component has its own detailed README:

- [SDK Documentation](SDK/README.md)
- [Client Documentation](Client/README.md)
- [Control Panel Documentation](ControlPanel/README.md)

## Project Structure

```
sleepy-powershell/
├── SDK/
│   ├── Sleepy.psm1         # Main SDK module
│   ├── Sleepy.psd1         # Module manifest
│   ├── Example-Usage.ps1   # Usage examples
│   └── README.md           # SDK documentation
├── Client/
│   ├── Sleepy-Client.ps1   # Background client
│   └── README.md           # Client documentation
├── ControlPanel/
│   ├── Sleepy-ControlPanel.ps1   # Control panel interface
│   └── README.md           # Control panel documentation
└── README.md              # This file
```

## Common Use Cases

1. **Automated Status Updates:**
   Use the Client for automatic status updates based on your active windows.

2. **Manual Status Management:**
   Use the Control Panel for manual status and device management.

3. **Custom Integration:**
   Use the SDK to build custom solutions or integrate with other tools.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or create issues for bugs and feature requests.

## License

This project is licensed under the GNU GPL v3 License - see each component's documentation for details.

## Authors

- NT_AUTHORITY
- SiiWay Team

## Support

For support, please create an issue in the GitHub repository or contact the development team.

