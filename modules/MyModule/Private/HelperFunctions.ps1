function Write-LogMessage {
    <#
    .SYNOPSIS
        Writes a formatted log message (private helper function).

    .DESCRIPTION
        This is an example of a private helper function that supports
        the public functions in the module but is not exported.

    .PARAMETER Message
        The message to log.

    .PARAMETER Level
        The log level (Info, Warning, Error).

    .PARAMETER Source
        The source of the log message.

    .EXAMPLE
        Write-LogMessage -Message "Operation completed" -Level "Info" -Source "Get-Something"
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Warning", "Error", "Debug")]
        [string]$Level = "Info",

        [Parameter(Mandatory = $false)]
        [string]$Source = "MyModule"
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] [$Source] $Message"

    switch ($Level) {
        "Info"    { Write-Information $LogEntry -InformationAction Continue }
        "Warning" { Write-Warning $LogEntry }
        "Error"   { Write-Error $LogEntry }
        "Debug"   { Write-Debug $LogEntry }
    }

    # Optional: Write to log file
    # $LogEntry | Out-File -FilePath $script:LogPath -Append -Encoding UTF8
}

function Test-Prerequisites {
    <#
    .SYNOPSIS
        Tests if prerequisites are met (private helper function).

    .DESCRIPTION
        Validates that required modules, permissions, or other prerequisites
        are available before executing main functionality.

    .EXAMPLE
        if (-not (Test-Prerequisites)) {
            throw "Prerequisites not met"
        }
    #>

    [CmdletBinding()]
    [OutputType([bool])]
    param()

    try {
        # Test PowerShell version
        if ($PSVersionTable.PSVersion.Major -lt 5) {
            Write-LogMessage -Message "PowerShell 5.0 or later is required" -Level "Error"
            return $false
        }

        # Test for required modules
        $RequiredModules = @("Microsoft.PowerShell.Management")
        foreach ($Module in $RequiredModules) {
            if (-not (Get-Module -Name $Module -ListAvailable)) {
                Write-LogMessage -Message "Required module not found: $Module" -Level "Error"
                return $false
            }
        }

        # Test for elevated privileges (if needed)
        $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
        if (-not $IsAdmin) {
            Write-LogMessage -Message "Some functions may require administrator privileges" -Level "Warning"
        }

        return $true
    }
    catch {
        Write-LogMessage -Message "Error checking prerequisites: $($_.Exception.Message)" -Level "Error"
        return $false
    }
}

function ConvertTo-SafePath {
    <#
    .SYNOPSIS
        Converts a path to a safe format (private helper function).

    .DESCRIPTION
        Ensures paths are properly formatted and safe to use,
        removing potentially dangerous characters.

    .PARAMETER Path
        The path to sanitize.

    .EXAMPLE
        $SafePath = ConvertTo-SafePath -Path $UserInput
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        # Remove invalid characters
        $InvalidChars = [IO.Path]::GetInvalidPathChars() -join ''
        $SafePath = $Path -replace "[$InvalidChars]", ''

        # Resolve relative paths
        if (-not [IO.Path]::IsPathRooted($SafePath)) {
            $SafePath = Join-Path -Path (Get-Location).Path -ChildPath $SafePath
        }

        # Normalize path separators
        $SafePath = [IO.Path]::GetFullPath($SafePath)

        Write-LogMessage -Message "Converted path: $Path -> $SafePath" -Level "Debug"
        return $SafePath
    }
    catch {
        Write-LogMessage -Message "Failed to convert path '$Path': $($_.Exception.Message)" -Level "Error"
        throw
    }
}
