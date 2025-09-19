function Get-Something {
    <#
    .SYNOPSIS
        Retrieves something from the system.

    .DESCRIPTION
        This function demonstrates the structure of a public module function.
        It includes proper comment-based help and follows PowerShell best practices.

    .PARAMETER Name
        Specifies the name of the item to retrieve.

    .PARAMETER ComputerName
        Specifies the computer to query. Default is localhost.

    .PARAMETER Credential
        Specifies credentials for remote access.

    .EXAMPLE
        PS C:\> Get-Something -Name "TestItem"

        Retrieves information about "TestItem" from the local computer.

    .EXAMPLE
        PS C:\> Get-Something -Name "TestItem" -ComputerName "Server01" -Credential (Get-Credential)

        Retrieves information about "TestItem" from Server01 using alternate credentials.

    .INPUTS
        System.String
        You can pipe names to this function.

    .OUTPUTS
        PSCustomObject
        Returns a custom object with the retrieved information.

    .NOTES
        Author: Your Name
        Date: 2025-01-01
        Version: 1.0.0
    #>

    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Enter the name of the item to retrieve"
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Name,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName = $(if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { [System.Net.Dns]::GetHostName() }),

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]$Credential
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand.Name)"

        # Initialize any required variables
        $Results = @()

        # Validate prerequisites
        $LocalHost = if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { [System.Net.Dns]::GetHostName() }
        if ($ComputerName -ne $LocalHost) {
            try {
                $null = Test-Connection -TargetName $ComputerName -Count 1 -Quiet -ErrorAction Stop
            }
            catch {
                throw "Cannot connect to computer: $ComputerName"
            }
        }
    }

    process {
        foreach ($ItemName in $Name) {
            try {
                Write-Verbose "Processing: $ItemName on $ComputerName"

                # Build script block for remote execution if needed
                $ScriptBlock = {
                    param($ItemName)

                    # Simulate retrieving something
                    [PSCustomObject]@{
                        Name = $ItemName
                        ComputerName = $env:COMPUTERNAME
                        Status = "Found"
                        Timestamp = Get-Date
                        Details = @{
                            Property1 = "Value1"
                            Property2 = "Value2"
                        }
                    }
                }

                # Execute locally or remotely
                $LocalHost = if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { [System.Net.Dns]::GetHostName() }
                if ($ComputerName -eq $LocalHost) {
                    $Result = & $ScriptBlock -ItemName $ItemName
                }
                else {
                    $InvokeParams = @{
                        ComputerName = $ComputerName
                        ScriptBlock = $ScriptBlock
                        ArgumentList = $ItemName
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
                Write-Error "Failed to process $ItemName on $ComputerName`: $($_.Exception.Message)"
            }
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand.Name)"
        Write-Verbose "Processed $($Results.Count) items"
    }
}
