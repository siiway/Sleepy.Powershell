@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'Sleepy.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # ID used to uniquely identify this module
    GUID = '8e3f9da3-5bd1-4e5a-b0e7-6c4534d8f234'

    # Author of this module
    Author = 'NT_AUTHORITY'

    # Company or vendor of this module
    CompanyName = 'SiiWay Team'

    # Copyright statement for this module
    Copyright = 'Copyright (c) 2025. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'PowerShell module for interacting with the Sleepy API'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Import-SleepyConfig',
        'Set-SleepyConfig',
        'Get-SleepyStatus',
        'Get-SleepyStatusList',
        'Set-SleepyStatus',
        'Set-SleepyDeviceStatus',
        'Remove-SleepyDevice',
        'Clear-SleepyDevices',
        'Set-SleepyPrivateMode',
        'Save-SleepyData',
        'Write-SleepyDebug'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Sleepy', 'API', 'Status')

            # A URL to the license for this module.
            LicenseUri = ''

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/wyf9/sleepy'

            # A URL to an icon representing this module.
            IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = 'Initial release of the Sleepy PowerShell module'
        }
    }
}
