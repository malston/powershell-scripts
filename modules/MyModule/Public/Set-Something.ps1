function Set-Something {
    <#
    .SYNOPSIS
        Sets configuration for specified items.

    .DESCRIPTION
        This function updates configuration values for specified items in the system.

    .PARAMETER Name
        Specifies the name of the item to configure.

    .PARAMETER Value
        Specifies the new value to set.

    .PARAMETER ComputerName
        Specifies the computer to configure. Default is localhost.

    .EXAMPLE
        PS C:\> Set-Something -Name "Config1" -Value "NewValue"

        Sets the value of Config1 to NewValue on the local computer.

    .EXAMPLE
        PS C:\> Set-Something -Name "Config1" -Value "NewValue" -ComputerName "Server01"

        Sets the value of Config1 to NewValue on Server01.
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [object]$Value,

        [Parameter(Mandatory = $false)]
        [string]$ComputerName = $(if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { [System.Net.Dns]::GetHostName() })
    )

    process {
        if ($PSCmdlet.ShouldProcess("$Name on $ComputerName", "Set value to $Value")) {
            Write-Verbose "Setting $Name to $Value on $ComputerName"

            [PSCustomObject]@{
                Name = $Name
                Value = $Value
                ComputerName = $ComputerName
                Status = "Updated"
                Timestamp = Get-Date
            }
        }
    }
}
