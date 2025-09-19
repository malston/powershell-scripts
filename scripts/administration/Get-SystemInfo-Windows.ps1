# Example script: Get-SystemInfo.ps1
# Purpose: Gather comprehensive system information

<#
.SYNOPSIS
    Gathers comprehensive system information from local or remote computers.

.DESCRIPTION
    This script collects various system information including hardware specs,
    operating system details, installed software, and system performance metrics.

.PARAMETER ComputerName
    Specifies the computer(s) to query. Accepts pipeline input.
    Default: localhost

.PARAMETER Credential
    Specifies credentials for remote computer access.

.PARAMETER IncludeHardware
    Include detailed hardware information in the output.

.PARAMETER IncludeSoftware
    Include installed software information in the output.

.PARAMETER OutputPath
    Specifies the path where the report will be saved.
    Default: Current directory

.EXAMPLE
    PS C:\> .\Get-SystemInfo.ps1

    Gathers system information from the local computer.

.EXAMPLE
    PS C:\> .\Get-SystemInfo.ps1 -ComputerName "Server01", "Server02" -IncludeHardware

    Gathers system and hardware information from multiple servers.

.EXAMPLE
    PS C:\> Get-Content servers.txt | .\Get-SystemInfo.ps1 -Credential (Get-Credential) -OutputPath "C:\Reports"

    Processes a list of servers from a file using alternate credentials.

.NOTES
    Author: Your Name
    Date: 2025-01-01
    Version: 1.0.0

    Requires PowerShell 5.1 or later.
    For remote computers, WinRM must be enabled and properly configured.
#>

[CmdletBinding()]
param(
    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
    )]
    [string[]]$ComputerName = $(if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { [System.Net.Dns]::GetHostName() }),

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.PSCredential]$Credential,

    [Parameter(Mandatory = $false)]
    [switch]$IncludeHardware,

    [Parameter(Mandatory = $false)]
    [switch]$IncludeSoftware,

    [Parameter(Mandatory = $false)]
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]$OutputPath = (Get-Location).Path
)

begin {
    Write-Verbose "Starting system information gathering"
    $Results = @()
    $ErrorActionPreference = 'Stop'
}

process {
    foreach ($Computer in $ComputerName) {
        try {
            Write-Verbose "Processing: $Computer"

            # Test connectivity
            if (-not (Test-Connection -ComputerName $Computer -Count 1 -Quiet)) {
                throw "Cannot connect to $Computer"
            }

            $ScriptBlock = {
                param($IncludeHW, $IncludeSW)

                # Basic system information
                $OS = Get-CimInstance -ClassName Win32_OperatingSystem
                $CS = Get-CimInstance -ClassName Win32_ComputerSystem
                $Processor = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1

                $SystemInfo = [PSCustomObject]@{
                    ComputerName = $env:COMPUTERNAME
                    OperatingSystem = $OS.Caption
                    OSVersion = $OS.Version
                    OSBuild = $OS.BuildNumber
                    ServicePack = $OS.ServicePackMajorVersion
                    Architecture = $OS.OSArchitecture
                    TotalMemoryGB = [Math]::Round($CS.TotalPhysicalMemory / 1GB, 2)
                    Manufacturer = $CS.Manufacturer
                    Model = $CS.Model
                    ProcessorName = $Processor.Name
                    ProcessorCores = $Processor.NumberOfCores
                    ProcessorLogicalCores = $Processor.NumberOfLogicalProcessors
                    LastBootTime = $OS.LastBootUpTime
                    Uptime = (Get-Date) - $OS.LastBootUpTime
                    TimeZone = (Get-TimeZone).Id
                    Domain = $CS.Domain
                    Workgroup = $CS.Workgroup
                    Timestamp = Get-Date
                }

                # Add hardware details if requested
                if ($IncludeHW) {
                    $Memory = Get-CimInstance -ClassName Win32_PhysicalMemory
                    $Disks = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
                    $NetworkAdapters = Get-CimInstance -ClassName Win32_NetworkAdapter | Where-Object { $_.NetConnectionStatus -eq 2 }

                    $SystemInfo | Add-Member -MemberType NoteProperty -Name "MemoryModules" -Value $Memory.Count
                    $SystemInfo | Add-Member -MemberType NoteProperty -Name "DiskDrives" -Value ($Disks | ForEach-Object {
                        [PSCustomObject]@{
                            Drive = $_.DeviceID
                            SizeGB = [Math]::Round($_.Size / 1GB, 2)
                            FreeSpaceGB = [Math]::Round($_.FreeSpace / 1GB, 2)
                            PercentFree = [Math]::Round(($_.FreeSpace / $_.Size) * 100, 1)
                        }
                    })
                    $SystemInfo | Add-Member -MemberType NoteProperty -Name "NetworkAdapters" -Value $NetworkAdapters.Count
                }

                # Add software information if requested
                if ($IncludeSW) {
                    $InstalledSoftware = Get-CimInstance -ClassName Win32_Product | Select-Object Name, Version, Vendor
                    $SystemInfo | Add-Member -MemberType NoteProperty -Name "InstalledSoftwareCount" -Value $InstalledSoftware.Count
                    $SystemInfo | Add-Member -MemberType NoteProperty -Name "InstalledSoftware" -Value $InstalledSoftware
                }

                return $SystemInfo
            }

            # Execute script block
            if ($Computer -eq $env:COMPUTERNAME) {
                $Result = & $ScriptBlock -IncludeHW $IncludeHardware -IncludeSW $IncludeSoftware
            }
            else {
                $InvokeParams = @{
                    ComputerName = $Computer
                    ScriptBlock = $ScriptBlock
                    ArgumentList = $IncludeHardware, $IncludeSoftware
                }

                if ($Credential) {
                    $InvokeParams.Credential = $Credential
                }

                $Result = Invoke-Command @InvokeParams
            }

            $Results += $Result
            Write-Output $Result

        }
        catch {
            Write-Error "Failed to process $Computer`: $($_.Exception.Message)"

            $ErrorResult = [PSCustomObject]@{
                ComputerName = $Computer
                Error = $_.Exception.Message
                Timestamp = Get-Date
            }

            $Results += $ErrorResult
        }
    }
}

end {
    Write-Verbose "Completed processing $($Results.Count) computers"

    # Export results to CSV
    if ($Results.Count -gt 0) {
        $OutputFile = Join-Path $OutputPath "SystemInfo-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
        $Results | Export-Csv -Path $OutputFile -NoTypeInformation
        Write-Host "Results exported to: $OutputFile" -ForegroundColor Green
    }
}
