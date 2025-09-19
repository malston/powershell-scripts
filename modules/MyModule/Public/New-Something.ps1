function New-Something {
    <#
    .SYNOPSIS
        Creates new items in the system.

    .DESCRIPTION
        This function creates new configuration items with specified properties.

    .PARAMETER Name
        Specifies the name of the item to create.

    .PARAMETER Properties
        Hashtable of properties for the new item.

    .PARAMETER ComputerName
        Specifies the computer where the item will be created. Default is localhost.

    .EXAMPLE
        PS C:\> New-Something -Name "NewItem" -Properties @{Type="Config"; Value="Initial"}

        Creates a new item with specified properties.

    .EXAMPLE
        PS C:\> New-Something -Name "NewItem" -Properties @{Type="Config"} -ComputerName "Server01"

        Creates a new item on Server01.
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [hashtable]$Properties = @{},

        [Parameter(Mandatory = $false)]
        [string]$ComputerName = $(if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { [System.Net.Dns]::GetHostName() })
    )

    process {
        if ($PSCmdlet.ShouldProcess("$Name on $ComputerName", "Create new item")) {
            Write-Verbose "Creating new item: $Name on $ComputerName"

            $NewItem = [PSCustomObject]@{
                Name = $Name
                ComputerName = $ComputerName
                Status = "Created"
                Timestamp = Get-Date
            }

            foreach ($Key in $Properties.Keys) {
                $NewItem | Add-Member -MemberType NoteProperty -Name $Key -Value $Properties[$Key]
            }

            Write-Output $NewItem
        }
    }
}
