# Modules Documentation

## MyModule

**Version:** 1.0.0
**Description:** Example module demonstrating PowerShell best practices

### Available Functions

#### Get-Something
Retrieves information about specified items.

```powershell
# Basic usage
Get-Something -Name "TestItem"

# With multiple items
Get-Something -Name "Item1", "Item2"

# Pipeline usage
"TestItem" | Get-Something

# Remote computer (if supported)
Get-Something -Name "TestItem" -ComputerName "Server01"
```

#### Set-Something
Updates configuration values for specified items.

```powershell
# Set a configuration value
Set-Something -Name "Config1" -Value "NewValue"

# With confirmation
Set-Something -Name "Config1" -Value "NewValue" -Confirm

# Remote computer
Set-Something -Name "Config1" -Value "NewValue" -ComputerName "Server01"
```

#### Test-Something
Validates whether specified items exist and meet defined criteria.

```powershell
# Test single item
Test-Something -Name "Config1"

# Test multiple items
"Config1", "Config2" | Test-Something

# Returns boolean value
if (Test-Something -Name "Config1") {
    Write-Host "Configuration exists"
}
```

#### New-Something
Creates new configuration items with specified properties.

```powershell
# Create basic item
New-Something -Name "NewItem"

# With properties
New-Something -Name "NewItem" -Properties @{
    Type = "Configuration"
    Value = "Initial"
    Priority = "High"
}

# With confirmation
New-Something -Name "NewItem" -WhatIf
```

### Module Structure

```
modules/MyModule/
├── MyModule.psd1        # Module manifest
├── MyModule.psm1        # Module loader
├── Public/              # Exported functions
│   ├── Get-Something.ps1
│   ├── Set-Something.ps1
│   ├── Test-Something.ps1
│   └── New-Something.ps1
└── Private/             # Internal helper functions
    └── HelperFunctions.ps1
```

### Getting Help

All functions include comprehensive help documentation:

```powershell
# Get help for any function
Get-Help Get-Something -Full

# See examples
Get-Help Get-Something -Examples

# Get online help (if available)
Get-Help Get-Something -Online
```

### Module Management

```powershell
# Import module
Import-Module .\modules\MyModule\MyModule.psd1

# Remove module
Remove-Module MyModule

# Force reload module
Import-Module .\modules\MyModule\MyModule.psd1 -Force

# List module commands
Get-Command -Module MyModule

# Get module info
Get-Module MyModule | Format-List
```

### Best Practices

1. **Always use approved verbs**: Get, Set, New, Remove, Test, etc.
2. **Include parameter validation**: Use ValidateScript, ValidateSet, etc.
3. **Support pipeline input**: Design functions to work with pipelines
4. **Provide verbose output**: Use Write-Verbose for debugging
5. **Include help documentation**: Always write comment-based help
6. **Handle errors gracefully**: Use try-catch blocks appropriately