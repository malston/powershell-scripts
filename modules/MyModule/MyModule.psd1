@{
    RootModule = 'MyModule.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author = 'Your Name'
    CompanyName = 'Your Company'
    Copyright = '(c) 2025 Your Name. All rights reserved.'
    Description = 'A PowerShell module for [describe functionality]'

    # Minimum PowerShell version required
    PowerShellVersion = '5.1'

    # Functions to export from this module
    FunctionsToExport = @(
        'Get-Something',
        'Set-Something',
        'Test-Something',
        'New-Something'
    )

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @()

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module
    ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    NestedModules = @()

    # List of all modules packaged with this module
    ModuleList = @()

    # List of all files packaged with this module
    FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData = @{
        PSData = @{
            # Tags applied to this module
            Tags = @('PowerShell', 'Automation', 'Utility')

            # A URL to the license for this module
            LicenseUri = 'https://github.com/yourusername/yourrepo/blob/main/LICENSE'

            # A URL to the main website for this project
            ProjectUri = 'https://github.com/yourusername/yourrepo'

            # A URL to an icon representing this module
            IconUri = ''

            # Release notes for this version
            ReleaseNotes = @'
## 1.0.0
- Initial release
- Added Get-Something function
- Added Set-Something function
- Added Test-Something function
- Added New-Something function
'@

            # Prerelease string of this module
            Prerelease = ''

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            RequireLicenseAcceptance = $false

            # External dependent modules of this module
            ExternalModuleDependencies = @()
        }
    }

    # HelpInfo URI of this module
    HelpInfoURI = 'https://github.com/yourusername/yourrepo/blob/main/docs/'

    # Default prefix for commands exported from this module
    DefaultCommandPrefix = ''
}
