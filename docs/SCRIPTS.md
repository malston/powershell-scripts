# Scripts Documentation

## Administration Scripts

Scripts for system administration and management tasks.

### Get-SystemInfo.ps1

**Purpose:** Gathers comprehensive system information (cross-platform)

**Location:** `scripts/administration/Get-SystemInfo.ps1`

**Features:**
- Works on Windows, macOS, and Linux
- Collects OS, hardware, and environment information
- Exports results to JSON format
- Platform-specific data collection

**Usage:**
```powershell
# Basic usage (local system)
.\scripts\administration\Get-SystemInfo.ps1

# Specify output directory
.\scripts\administration\Get-SystemInfo.ps1 -OutputPath "C:\Reports"

# With verbose output
.\scripts\administration\Get-SystemInfo.ps1 -Verbose
```

**Output:**
- Console display of system information
- JSON file: `SystemInfo-YYYYMMDD-HHmmss.json`

### Get-SystemInfo-Windows.ps1

**Purpose:** Windows-specific system information with advanced features

**Location:** `scripts/administration/Get-SystemInfo-Windows.ps1`

**Features:**
- Windows-only with WMI/CIM cmdlets
- Remote computer support
- Credential support
- Hardware and software inventory
- Multiple computer processing

**Usage:**
```powershell
# Local computer
.\scripts\administration\Get-SystemInfo-Windows.ps1

# Remote computers
.\scripts\administration\Get-SystemInfo-Windows.ps1 -ComputerName "Server01", "Server02"

# With credentials
$cred = Get-Credential
.\scripts\administration\Get-SystemInfo-Windows.ps1 -ComputerName "Server01" -Credential $cred

# Include hardware details
.\scripts\administration\Get-SystemInfo-Windows.ps1 -IncludeHardware

# Include software inventory
.\scripts\administration\Get-SystemInfo-Windows.ps1 -IncludeSoftware

# Full inventory with output path
.\scripts\administration\Get-SystemInfo-Windows.ps1 `
    -ComputerName "Server01", "Server02" `
    -IncludeHardware `
    -IncludeSoftware `
    -OutputPath "C:\Reports"
```

**Requirements:**
- Windows PowerShell 5.1+ or PowerShell Core on Windows
- WinRM enabled for remote computers
- Appropriate permissions for WMI queries

## Automation Scripts

*Coming soon...*

## Utility Scripts

*Coming soon...*

## Script Development Guidelines

### Structure
```powershell
<#
.SYNOPSIS
    Brief description

.DESCRIPTION
    Detailed description

.PARAMETER ParameterName
    Parameter description

.EXAMPLE
    Usage example
#>

[CmdletBinding()]
param(
    # Parameters
)

begin {
    # Initialization
}

process {
    # Main logic
}

end {
    # Cleanup
}
```

### Best Practices

1. **Always include help**: Use comment-based help at the top
2. **Use CmdletBinding**: Enable advanced function features
3. **Validate parameters**: Use parameter attributes
4. **Handle errors**: Implement proper error handling
5. **Provide verbose output**: Use Write-Verbose for debugging
6. **Follow naming conventions**: Use Verb-Noun format
7. **Test thoroughly**: Write Pester tests for your scripts