function Test-Something {
    <#
    .SYNOPSIS
        Tests if specified items meet certain conditions.

    .DESCRIPTION
        This function validates whether specified items exist and meet defined criteria.

    .PARAMETER Name
        Specifies the name of the item to test.

    .PARAMETER ComputerName
        Specifies the computer to test. Default is localhost.

    .EXAMPLE
        PS C:\> Test-Something -Name "Config1"

        Tests if Config1 exists on the local computer.

    .EXAMPLE
        PS C:\> "Config1", "Config2" | Test-Something

        Tests multiple configurations using pipeline input.
    #>

    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Name,

        [Parameter(Mandatory = $false)]
        [string]$ComputerName = $(if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { [System.Net.Dns]::GetHostName() })
    )

    process {
        foreach ($ItemName in $Name) {
            Write-Verbose "Testing $ItemName on $ComputerName"

            # Simulate test logic
            $TestResult = $true

            if ($TestResult) {
                Write-Verbose "$ItemName exists and is valid"
                $true
            }
            else {
                Write-Verbose "$ItemName does not exist or is invalid"
                $false
            }
        }
    }
}
