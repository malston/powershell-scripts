# Install-PowerCLI.ps1
# Purpose: Install and configure VMware PowerCLI (VCF.PowerCLI)

<#
.SYNOPSIS
    Installs VMware PowerCLI module with proper configuration.

.DESCRIPTION
    This script automates the installation of VMware PowerCLI (VCF.PowerCLI) from the PowerShell Gallery.
    It handles prerequisites, installation, configuration, and verification.
    Supports both online and offline installation methods.

.PARAMETER InstallationType
    Specifies the installation type: Online or Offline
    Default: Online

.PARAMETER OfflineZipPath
    Path to the offline PowerCLI .zip file (required for offline installation)

.PARAMETER Force
    Forces reinstallation even if PowerCLI is already installed

.PARAMETER SkipPowerShellCheck
    Skips the PowerShell version check (not recommended)

.PARAMETER Scope
    Installation scope: CurrentUser or AllUsers
    Default: CurrentUser

.EXAMPLE
    PS> .\Install-PowerCLI.ps1

    Performs online installation for current user.

.EXAMPLE
    PS> .\Install-PowerCLI.ps1 -InstallationType Offline -OfflineZipPath "C:\Downloads\VCF.PowerCLI.zip"

    Performs offline installation from downloaded zip file.

.EXAMPLE
    PS> .\Install-PowerCLI.ps1 -Force -Scope AllUsers

    Forces reinstallation for all users (requires admin rights).

.NOTES
    Author: PowerShell Scripts Repository
    Date: 2025-01-19
    Version: 1.0.0

    Requirements:
    - PowerShell 7.4+ (recommended)
    - Internet connection (for online installation)
    - Administrator rights (for AllUsers scope)
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('Online', 'Offline')]
    [string]$InstallationType = 'Online',

    [Parameter(Mandatory = $false)]
    [ValidateScript({
        if ($_ -and -not (Test-Path $_)) {
            throw "Offline zip file not found: $_"
        }
        $true
    })]
    [string]$OfflineZipPath,

    [Parameter(Mandatory = $false)]
    [switch]$Force,

    [Parameter(Mandatory = $false)]
    [switch]$SkipPowerShellCheck,

    [Parameter(Mandatory = $false)]
    [ValidateSet('CurrentUser', 'AllUsers')]
    [string]$Scope = 'CurrentUser'
)

begin {
    # Script configuration
    $Script:Config = @{
        ModuleName = 'VCF.PowerCLI'
        OldModuleName = 'VMware.PowerCLI'
        MinPowerShellVersion = [Version]'7.4.0'
        RecommendedPowerShellVersion = [Version]'7.4.0'
        DeprecatedPowerShellVersion = [Version]'5.1.0'
    }

    # Helper functions
    function Write-ColorOutput {
        param(
            [string]$Message,
            [string]$Type = 'Info'
        )

        $Color = switch ($Type) {
            'Success' { 'Green' }
            'Warning' { 'Yellow' }
            'Error' { 'Red' }
            'Info' { 'Cyan' }
            default { 'White' }
        }

        Write-Host $Message -ForegroundColor $Color
    }

    function Test-Administrator {
        if ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop') {
            $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
            $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
            return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        }
        elseif ($IsMacOS -or $IsLinux) {
            return (id -u) -eq 0
        }
        return $false
    }

    function Test-PowerShellVersion {
        $currentVersion = $PSVersionTable.PSVersion

        Write-ColorOutput "`nChecking PowerShell version..." -Type Info
        Write-Host "Current PowerShell version: $currentVersion"

        if ($currentVersion -lt $Script:Config.MinPowerShellVersion) {
            Write-ColorOutput "WARNING: PowerShell $currentVersion is below the recommended version $($Script:Config.RecommendedPowerShellVersion)" -Type Warning

            if ($currentVersion.Major -eq 5 -and $currentVersion.Minor -eq 1) {
                Write-ColorOutput "IMPORTANT: PowerShell 5.1 is being deprecated for PowerCLI" -Type Warning
                Write-ColorOutput "Please upgrade to PowerShell 7.4 or later for best compatibility" -Type Warning

                if (-not $SkipPowerShellCheck) {
                    $response = Read-Host "Do you want to continue anyway? (not recommended) [y/N]"
                    if ($response -ne 'y') {
                        Write-ColorOutput "Installation cancelled. Please upgrade PowerShell first." -Type Error
                        Write-Host "`nTo install PowerShell 7, visit: https://aka.ms/powershell"
                        return $false
                    }
                }
            }
        }
        else {
            Write-ColorOutput "PowerShell version check passed ✓" -Type Success
        }

        return $true
    }

    function Test-ExistingInstallation {
        Write-ColorOutput "`nChecking for existing PowerCLI installations..." -Type Info

        # Check for new module
        $newModule = Get-Module -Name $Script:Config.ModuleName -ListAvailable
        if ($newModule) {
            Write-Host "Found VCF.PowerCLI version(s): $($newModule.Version -join ', ')"
            return $newModule
        }

        # Check for old VMware.PowerCLI
        $oldModule = Get-Module -Name $Script:Config.OldModuleName -ListAvailable
        if ($oldModule) {
            Write-ColorOutput "Found legacy VMware.PowerCLI version(s): $($oldModule.Version -join ', ')" -Type Warning
            Write-ColorOutput "It's recommended to uninstall VMware.PowerCLI before installing VCF.PowerCLI" -Type Warning

            $response = Read-Host "Do you want to uninstall VMware.PowerCLI first? [Y/n]"
            if ($response -ne 'n') {
                Write-Host "Uninstalling VMware.PowerCLI..."
                try {
                    Uninstall-Module -Name $Script:Config.OldModuleName -AllVersions -Force -ErrorAction Stop
                    Write-ColorOutput "Successfully uninstalled VMware.PowerCLI" -Type Success
                }
                catch {
                    Write-ColorOutput "Failed to uninstall VMware.PowerCLI: $_" -Type Error
                    Write-Host "You may need to manually uninstall it with administrator privileges"
                }
            }
        }

        return $null
    }

    function Install-PowerCLIOnline {
        param([string]$InstallScope)

        Write-ColorOutput "`nInstalling VCF.PowerCLI from PowerShell Gallery..." -Type Info

        $installParams = @{
            Name = $Script:Config.ModuleName
            Scope = $InstallScope
            Force = $true
            AllowClobber = $true
            SkipPublisherCheck = $true
            ErrorAction = 'Stop'
        }

        if ($PSCmdlet.ShouldProcess("VCF.PowerCLI", "Install from PowerShell Gallery")) {
            try {
                Install-Module @installParams
                Write-ColorOutput "Successfully installed VCF.PowerCLI" -Type Success
                return $true
            }
            catch {
                Write-ColorOutput "Failed to install VCF.PowerCLI: $_" -Type Error

                # Try with additional parameters for common issues
                if ($_.Exception.Message -match 'certificate|publisher') {
                    Write-Host "Retrying with relaxed security settings..."
                    $installParams.Add('AcceptLicense', $true)
                    try {
                        Install-Module @installParams
                        Write-ColorOutput "Successfully installed VCF.PowerCLI (with relaxed settings)" -Type Success
                        return $true
                    }
                    catch {
                        Write-ColorOutput "Installation failed: $_" -Type Error
                        return $false
                    }
                }
                return $false
            }
        }
    }

    function Install-PowerCLIOffline {
        param(
            [string]$ZipPath,
            [string]$InstallScope
        )

        Write-ColorOutput "`nInstalling VCF.PowerCLI from offline package..." -Type Info

        # Determine module path based on scope
        if ($InstallScope -eq 'AllUsers') {
            if ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop') {
                $modulePath = "$env:ProgramFiles\PowerShell\Modules"
            }
            else {
                $modulePath = "/usr/local/share/powershell/Modules"
            }
        }
        else {
            if ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop') {
                $modulePath = "$HOME\Documents\PowerShell\Modules"
            }
            else {
                $modulePath = "$HOME/.local/share/powershell/Modules"
            }
        }

        if (-not (Test-Path $modulePath)) {
            New-Item -Path $modulePath -ItemType Directory -Force | Out-Null
        }

        Write-Host "Extracting to: $modulePath"

        if ($PSCmdlet.ShouldProcess($ZipPath, "Extract to $modulePath")) {
            try {
                # Extract the archive
                Expand-Archive -Path $ZipPath -DestinationPath $modulePath -Force

                # Unblock all files (Windows only)
                if ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop') {
                    Write-Host "Unblocking extracted files..."
                    Get-ChildItem "$modulePath\$($Script:Config.ModuleName)" -Recurse | Unblock-File
                }

                Write-ColorOutput "Successfully installed VCF.PowerCLI from offline package" -Type Success
                return $true
            }
            catch {
                Write-ColorOutput "Failed to install from offline package: $_" -Type Error
                return $false
            }
        }
    }

    function Test-PowerCLIInstallation {
        Write-ColorOutput "`nVerifying PowerCLI installation..." -Type Info

        try {
            $module = Get-Module -Name $Script:Config.ModuleName -ListAvailable | Select-Object -First 1
            if ($module) {
                Write-ColorOutput "PowerCLI installation verified ✓" -Type Success
                Write-Host "Module Name: $($module.Name)"
                Write-Host "Version: $($module.Version)"
                Write-Host "Path: $($module.ModuleBase)"

                # Try to import the module
                Write-Host "`nTesting module import..."
                Import-Module -Name $Script:Config.ModuleName -ErrorAction Stop
                Write-ColorOutput "Module imported successfully ✓" -Type Success

                # Show available commands
                $commands = Get-Command -Module $Script:Config.ModuleName | Select-Object -First 5
                if ($commands) {
                    Write-Host "`nSample commands available:"
                    $commands | ForEach-Object { Write-Host "  - $($_.Name)" }
                }

                return $true
            }
            else {
                Write-ColorOutput "PowerCLI module not found" -Type Error
                return $false
            }
        }
        catch {
            Write-ColorOutput "Failed to verify installation: $_" -Type Error
            return $false
        }
    }
}

process {
    Write-ColorOutput "`n========================================" -Type Info
    Write-ColorOutput "    VMware PowerCLI Installation Script" -Type Info
    Write-ColorOutput "========================================" -Type Info

    # Check if running as administrator if AllUsers scope
    if ($Scope -eq 'AllUsers' -and -not (Test-Administrator)) {
        Write-ColorOutput "ERROR: Administrator privileges required for AllUsers installation" -Type Error
        Write-Host "Please run this script as Administrator or use -Scope CurrentUser"
        return
    }

    # Check PowerShell version
    if (-not (Test-PowerShellVersion)) {
        return
    }

    # Check for existing installations
    $existingModule = Test-ExistingInstallation
    if ($existingModule -and -not $Force) {
        Write-ColorOutput "`nVCF.PowerCLI is already installed" -Type Success
        $response = Read-Host "Do you want to update/reinstall? [y/N]"
        if ($response -ne 'y') {
            Write-Host "Installation cancelled"
            return
        }
    }

    # Perform installation based on type
    $installSuccess = $false

    switch ($InstallationType) {
        'Online' {
            # Check internet connectivity
            Write-Host "`nChecking internet connectivity..."
            try {
                $null = Invoke-WebRequest -Uri "https://www.powershellgallery.com" -UseBasicParsing -TimeoutSec 5
                Write-ColorOutput "Internet connectivity confirmed ✓" -Type Success
            }
            catch {
                Write-ColorOutput "Cannot reach PowerShell Gallery. Please check your internet connection or use offline installation." -Type Error
                return
            }

            $installSuccess = Install-PowerCLIOnline -InstallScope $Scope
        }

        'Offline' {
            if (-not $OfflineZipPath) {
                Write-ColorOutput "ERROR: OfflineZipPath is required for offline installation" -Type Error
                Write-Host "Please provide the path to the VCF.PowerCLI .zip file"
                Write-Host "Example: .\Install-PowerCLI.ps1 -InstallationType Offline -OfflineZipPath 'C:\Downloads\VCF.PowerCLI.zip'"
                return
            }

            $installSuccess = Install-PowerCLIOffline -ZipPath $OfflineZipPath -InstallScope $Scope
        }
    }

    # Verify installation
    if ($installSuccess) {
        $verified = Test-PowerCLIInstallation

        if ($verified) {
            Write-ColorOutput "`n========================================" -Type Success
            Write-ColorOutput "   PowerCLI Installation Complete! 🎉" -Type Success
            Write-ColorOutput "========================================" -Type Success

            Write-Host "`nNext steps:"
            Write-Host "1. Connect to vCenter: Connect-VIServer -Server vcenter.example.com"
            Write-Host "2. View available commands: Get-Command -Module VCF.PowerCLI"
            Write-Host "3. Get help: Get-Help <command-name> -Full"

            # Check for updates
            Write-Host "`nTo check for updates in the future, run:"
            Write-Host "  Update-Module -Name VCF.PowerCLI"
        }
    }
    else {
        Write-ColorOutput "`nInstallation failed. Please check the errors above and try again." -Type Error
        Write-Host "`nFor manual installation instructions, visit:"
        Write-Host "https://developer.broadcom.com/powercli/installation-guide"
    }
}

end {
    Write-Verbose "Installation script completed"
}
