# Get-SystemInfo.ps1

<#
.SYNOPSIS
    Gathers system information in a cross-platform manner.

.DESCRIPTION
    This script collects system information that works on Windows, macOS, and Linux.

.PARAMETER OutputPath
    Specifies the path where the report will be saved.

.EXAMPLE
    PS> .\Get-SystemInfo.ps1

    Gathers system information from the local computer.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]$OutputPath = (Get-Location).Path
)

Write-Verbose "Gathering system information"

# Gather system information
$SystemInfo = [PSCustomObject]@{
    ComputerName = [System.Net.Dns]::GetHostName()
    Platform = [System.Environment]::OSVersion.Platform
    OSDescription = [System.Runtime.InteropServices.RuntimeInformation]::OSDescription
    OSArchitecture = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
    ProcessArchitecture = [System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture
    FrameworkDescription = [System.Runtime.InteropServices.RuntimeInformation]::FrameworkDescription
    PowerShellVersion = $PSVersionTable.PSVersion.ToString()
    PowerShellEdition = $PSVersionTable.PSEdition
    CLRVersion = $PSVersionTable.CLRVersion
    WSManStackVersion = $PSVersionTable.WSManStackVersion
    SerializationVersion = $PSVersionTable.SerializationVersion
    ProcessorCount = [System.Environment]::ProcessorCount
    UserName = [System.Environment]::UserName
    UserDomainName = [System.Environment]::UserDomainName
    MachineName = [System.Environment]::MachineName
    SystemDirectory = [System.Environment]::SystemDirectory
    CurrentDirectory = [System.Environment]::CurrentDirectory
    TempPath = [System.IO.Path]::GetTempPath()
    HomePath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile)
    Is64BitOperatingSystem = [System.Environment]::Is64BitOperatingSystem
    Is64BitProcess = [System.Environment]::Is64BitProcess
    TickCount = [System.Environment]::TickCount64
    WorkingSet = [System.Environment]::WorkingSet
    Timestamp = Get-Date
}

# Add platform-specific information
if ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop') {
    $SystemInfo | Add-Member -MemberType NoteProperty -Name "WindowsDirectory" -Value [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Windows)
    $SystemInfo | Add-Member -MemberType NoteProperty -Name "ProgramFiles" -Value [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ProgramFiles)
}

if ($IsMacOS) {
    # macOS specific information
    try {
        $SwVers = & sw_vers
        $SystemInfo | Add-Member -MemberType NoteProperty -Name "macOSVersion" -Value ($SwVers -join "; ")

        $SysCtl = & sysctl -n hw.memsize
        $MemoryGB = [Math]::Round($SysCtl / 1GB, 2)
        $SystemInfo | Add-Member -MemberType NoteProperty -Name "TotalMemoryGB" -Value $MemoryGB
    }
    catch {
        Write-Verbose "Could not retrieve macOS specific information"
    }
}

if ($IsLinux) {
    # Linux specific information
    try {
        if (Test-Path "/etc/os-release") {
            $OSRelease = Get-Content "/etc/os-release" | ConvertFrom-StringData
            $SystemInfo | Add-Member -MemberType NoteProperty -Name "LinuxDistribution" -Value $OSRelease.PRETTY_NAME
        }

        if (Test-Path "/proc/meminfo") {
            $MemInfo = Get-Content "/proc/meminfo" | Select-String "MemTotal"
            if ($MemInfo) {
                $MemKB = [regex]::Match($MemInfo, '\d+').Value
                $MemoryGB = [Math]::Round([int]$MemKB / 1024 / 1024, 2)
                $SystemInfo | Add-Member -MemberType NoteProperty -Name "TotalMemoryGB" -Value $MemoryGB
            }
        }
    }
    catch {
        Write-Verbose "Could not retrieve Linux specific information"
    }
}

# Get environment variables
$EnvironmentVars = [System.Environment]::GetEnvironmentVariables()
$SystemInfo | Add-Member -MemberType NoteProperty -Name "EnvironmentVariableCount" -Value $EnvironmentVars.Count

# Get drives/volumes
try {
    $Drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -or $_.Free } | ForEach-Object {
        [PSCustomObject]@{
            Name = $_.Name
            Root = $_.Root
            UsedGB = if ($_.Used) { [Math]::Round($_.Used / 1GB, 2) } else { 0 }
            FreeGB = if ($_.Free) { [Math]::Round($_.Free / 1GB, 2) } else { 0 }
            TotalGB = if ($_.Used -and $_.Free) { [Math]::Round(($_.Used + $_.Free) / 1GB, 2) } else { 0 }
        }
    }
    $SystemInfo | Add-Member -MemberType NoteProperty -Name "Drives" -Value $Drives
}
catch {
    Write-Verbose "Could not retrieve drive information"
}

# Display the information
$SystemInfo | Format-List

# Export to file
$OutputFile = Join-Path $OutputPath "SystemInfo-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$SystemInfo | ConvertTo-Json -Depth 3 | Out-File $OutputFile
Write-Host "Results exported to: $OutputFile" -ForegroundColor Green

# Return the object
Write-Output $SystemInfo
