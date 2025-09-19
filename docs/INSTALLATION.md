# Installation Guide

## Prerequisites

- PowerShell 5.1+ or PowerShell Core 7+
- Git (for version control)
- Pester 5.0+ (for testing)

## Installation Steps

### 1. Clone the Repository

```powershell
# Clone the repository
git clone https://github.com/yourusername/powershell-scripts.git
cd powershell-scripts
```

### 2. Install Required Modules

```powershell
# Install Pester for testing
Install-Module -Name Pester -Force -SkipPublisherCheck

# Install PSScriptAnalyzer for code analysis
Install-Module -Name PSScriptAnalyzer -Force
```

### 3. Import the Module

```powershell
# Import the module
Import-Module .\modules\MyModule\MyModule.psd1

# Verify module is loaded
Get-Module MyModule
```

### 4. Verify Installation

```powershell
# Run a sample script
.\scripts\administration\Get-SystemInfo.ps1

# Test a module function
Get-Something -Name "TestItem"

# Run tests to ensure everything works
Invoke-Pester .\tests\
```

## Platform-Specific Notes

### macOS / Linux
- Ensure PowerShell Core (`pwsh`) is installed
- The main scripts are cross-platform compatible
- Use `Get-SystemInfo.ps1` for system information

### Windows
- Works with both Windows PowerShell and PowerShell Core
- Use `Get-SystemInfo-Windows.ps1` for advanced Windows-specific features
- WinRM must be enabled for remote computer management

## VS Code Integration

If using Visual Studio Code:

1. Install the PowerShell extension
2. Open the project folder
3. VS Code settings are pre-configured in `.vscode/`
4. Press F5 to run scripts with debugging support

## Troubleshooting

### Module won't import
- Check PowerShell execution policy: `Get-ExecutionPolicy`
- Set to RemoteSigned if needed: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

### Scripts won't run on macOS/Linux
- Ensure you're using PowerShell Core (`pwsh`), not Windows PowerShell
- Check file permissions: `chmod +x script.ps1` if needed

### Missing dependencies
- Run `Get-Module -ListAvailable` to see installed modules
- Install missing modules using `Install-Module`