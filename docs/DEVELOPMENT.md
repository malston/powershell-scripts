# Development Guide

## Code Style Guidelines

### PowerShell Best Practices

#### Naming Conventions
- **Functions**: Use approved verbs (Get-, Set-, New-, Remove-, Test-, etc.) with PascalCase nouns
- **Variables**: Use camelCase for local variables, PascalCase for global/script scope
- **Parameters**: Use PascalCase for parameter names
- **Private Functions**: Consider prefixing with underscore or using verb like `Initialize-`

#### Code Formatting
- Follow OTBS (One True Brace Style) - configured in VS Code
- Use 4 spaces for indentation (no tabs)
- Include spaces around operators and after commas
- Keep lines under 120 characters when possible

### Function Structure

```powershell
function Get-ExampleFunction {
    <#
    .SYNOPSIS
        Brief description of the function

    .DESCRIPTION
        Detailed description of what the function does

    .PARAMETER ParameterName
        Description of the parameter

    .EXAMPLE
        Get-ExampleFunction -ParameterName "Value"

        Description of what this example does

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
            HelpMessage = "Enter the parameter value"
        )]
        [ValidateNotNullOrEmpty()]
        [string]$ParameterName
    )

    begin {
        # Initialization code
        Write-Verbose "Starting $($MyInvocation.MyCommand.Name)"
    }

    process {
        # Main processing logic
        try {
            # Your code here
        }
        catch {
            Write-Error "An error occurred: $_"
            throw
        }
    }

    end {
        # Cleanup code
        Write-Verbose "Completed $($MyInvocation.MyCommand.Name)"
    }
}
```

## Adding New Features

### Creating a New Module Function

1. **Create the function file** in `modules/MyModule/Public/`
   ```powershell
   # File: Verb-Noun.ps1
   function Verb-Noun {
       # Implementation
   }
   ```

2. **Update the module manifest** (`MyModule.psd1`)
   ```powershell
   FunctionsToExport = @(
       'Get-Something',
       'Verb-Noun'  # Add your new function
   )
   ```

3. **Write tests** in `tests/`
   ```powershell
   Describe "Verb-Noun" {
       It "Should perform expected action" {
           # Test implementation
       }
   }
   ```

4. **Update documentation**
   - Add function details to `docs/MODULES.md`
   - Update README if it's a major feature

### Creating a New Script

1. **Choose appropriate directory**
   - `scripts/administration/` - System administration tasks
   - `scripts/automation/` - Automation workflows
   - `scripts/utilities/` - General utilities

2. **Follow the template structure**
   - Include comprehensive help
   - Use parameter validation
   - Implement error handling
   - Add verbose output

3. **Make it cross-platform when possible**
   - Test on Windows, macOS, and Linux
   - Use .NET methods over OS-specific commands
   - Document platform requirements

## Build Process

### Using the Build Script

```powershell
# Clean build artifacts
.\tools\build.ps1 -Task Clean

# Build the module
.\tools\build.ps1 -Task Build

# Run tests
.\tools\build.ps1 -Task Test

# Run code analysis
.\tools\build.ps1 -Task Analyze

# Package for distribution
.\tools\build.ps1 -Task Package

# Full build pipeline
.\tools\build.ps1 -Task All
```

### Build Configuration

Edit `tools/build.ps1` to customize:
- Module name and version
- Output paths
- Test configuration
- Package settings

## Version Control

### Commit Message Format

Follow conventional commits:

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style changes
- `refactor`: Code restructuring
- `test`: Test additions or fixes
- `chore`: Maintenance tasks

**Examples:**
```
feat(module): add Remove-Something function
fix(scripts): resolve cross-platform compatibility issue
docs(readme): update installation instructions
test(module): add tests for error handling
```

### Branch Strategy

- `main` - Stable, production-ready code
- `develop` - Integration branch for features
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Critical production fixes

## Debugging

### VS Code Debugging

1. Set breakpoints by clicking left of line numbers
2. Press F5 to start debugging
3. Use Debug Console for interactive debugging

### PowerShell Debugging Commands

```powershell
# Enable debug output
$DebugPreference = "Continue"

# Set breakpoints in code
Set-PSBreakpoint -Script .\script.ps1 -Line 10

# List breakpoints
Get-PSBreakpoint

# Remove breakpoints
Remove-PSBreakpoint -Id 0

# Step through code
Set-PSDebug -Step

# Trace execution
Set-PSDebug -Trace 2

# Disable debugging
Set-PSDebug -Off
```

### Verbose and Debug Output

```powershell
# In your functions
Write-Verbose "Detailed information for -Verbose"
Write-Debug "Debug information for -Debug"

# When calling functions
Get-Something -Verbose
Get-Something -Debug
```

## Performance Optimization

### Best Practices

1. **Use pipeline efficiently**
   ```powershell
   # Good - processes one at a time
   Get-Process | Where-Object CPU -gt 10

   # Avoid - loads everything into memory
   $procs = Get-Process
   $procs | Where-Object CPU -gt 10
   ```

2. **Filter left, format right**
   ```powershell
   # Good
   Get-Process | Where-Object Name -eq "pwsh" | Format-Table

   # Avoid
   Get-Process | Format-Table | Where-Object Name -eq "pwsh"
   ```

3. **Use .NET methods for performance-critical code**
   ```powershell
   # Faster
   [System.IO.File]::ReadAllText($path)

   # Slower
   Get-Content $path -Raw
   ```

## Security Considerations

1. **Never hardcode credentials**
   - Use `Get-Credential` or secure strings
   - Store in credential managers
   - Use environment variables for CI/CD

2. **Validate all input**
   - Use parameter validation attributes
   - Sanitize user input
   - Validate file paths

3. **Follow principle of least privilege**
   - Request only necessary permissions
   - Use `-WhatIf` and `-Confirm` for destructive operations
   - Document permission requirements

4. **Handle sensitive data properly**
   - Don't log passwords or keys
   - Use SecureString for passwords
   - Clean up sensitive variables

## Resources

- [PowerShell Best Practices](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/strongly-encouraged-development-guidelines)
- [PSScriptAnalyzer Rules](https://github.com/PowerShell/PSScriptAnalyzer/blob/master/docs/Rules)
- [Pester Documentation](https://pester.dev/docs/quick-start)
- [PowerShell Style Guide](https://poshcode.gitbook.io/powershell-practice-and-style/)