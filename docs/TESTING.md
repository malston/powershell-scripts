# Testing Guide

## Overview

This project uses Pester, the PowerShell testing framework, for unit testing and validation.

## Running Tests

### Run All Tests
```powershell
# Basic test run
Invoke-Pester .\tests\

# With detailed output
Invoke-Pester .\tests\ -Output Detailed

# With code coverage
$config = New-PesterConfiguration
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path = '.\modules\**\*.ps1'
$config.Output.Verbosity = 'Detailed'
Invoke-Pester -Configuration $config
```

### Run Specific Tests
```powershell
# Run tests for a specific module
Invoke-Pester .\tests\MyModule.Tests.ps1

# Run tests matching a pattern
Invoke-Pester -Path .\tests\ -TestName "*Get-Something*"

# Run with tags (if implemented)
Invoke-Pester -Tag "Unit"
```

### VS Code Integration
- Press `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (Mac)
- Select "Tasks: Run Task"
- Choose "Run Pester Tests"

Or use the command palette to run tests for the current file.

## Test Structure

### Test Files
Tests are located in the `tests/` directory with the naming convention `*.Tests.ps1`

### Test Organization
```powershell
BeforeAll {
    # Setup that runs once before all tests
    Import-Module $ModulePath -Force
}

Describe "Component Name" {
    Context "Specific Scenario" {
        It "Should do something specific" {
            # Test implementation
            $result = Get-Something -Name "Test"
            $result | Should -Not -BeNullOrEmpty
        }
    }
}

AfterAll {
    # Cleanup that runs once after all tests
    Remove-Module MyModule -Force
}
```

## Writing Tests

### Basic Assertions
```powershell
# Value comparisons
$result | Should -Be "Expected"
$result | Should -Not -Be "NotExpected"
$result | Should -BeExactly "ExactMatch"

# Null checks
$result | Should -Not -BeNullOrEmpty
$result | Should -BeNull

# Type checks
$result | Should -BeOfType [string]
$result | Should -BeOfType [PSCustomObject]

# Collection assertions
$collection | Should -Contain "Item"
$collection | Should -HaveCount 5

# String matching
$result | Should -Match "pattern"
$result | Should -BeLike "*wildcard*"

# Exceptions
{ Get-Something -Name $null } | Should -Throw
{ Get-Something -Name "Valid" } | Should -Not -Throw
```

### Mocking
```powershell
Describe "Function with dependencies" {
    BeforeAll {
        Mock Test-Connection { return $true }
        Mock Get-Process {
            return [PSCustomObject]@{
                Name = "MockProcess"
                Id = 1234
            }
        }
    }

    It "Should use mocked dependencies" {
        # Your test that uses the mocked functions
        $result = Get-Something -Name "Test"

        # Verify mock was called
        Should -Invoke Test-Connection -Times 1
    }
}
```

### Test Data
```powershell
Describe "Parameterized Tests" {
    $testCases = @(
        @{ Name = "Test1"; Expected = "Result1" }
        @{ Name = "Test2"; Expected = "Result2" }
        @{ Name = "Test3"; Expected = "Result3" }
    )

    It "Should process <Name> correctly" -TestCases $testCases {
        param($Name, $Expected)

        $result = Get-Something -Name $Name
        $result | Should -Be $Expected
    }
}
```

## Code Coverage

### Running Coverage Analysis
```powershell
# Configure coverage
$config = New-PesterConfiguration
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path = @(
    '.\modules\MyModule\Public\*.ps1'
    '.\modules\MyModule\Private\*.ps1'
)
$config.CodeCoverage.OutputFormat = 'JaCoCo'
$config.CodeCoverage.OutputPath = '.\coverage.xml'

# Run with coverage
Invoke-Pester -Configuration $config
```

### Coverage Targets
- Aim for at least 80% code coverage
- Critical functions should have 100% coverage
- Focus on testing business logic and error paths

## Continuous Integration

### GitHub Actions Example
```yaml
name: PowerShell Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: windows-latest
    steps:
    - uses: actions/checkout@v2

    - name: Run Pester Tests
      shell: pwsh
      run: |
        Install-Module -Name Pester -Force
        Invoke-Pester -Path .\tests\ -Output Detailed
```

## Best Practices

1. **Test One Thing**: Each test should validate one specific behavior
2. **Use Descriptive Names**: Test names should clearly state what is being tested
3. **Arrange-Act-Assert**: Structure tests with setup, execution, and validation
4. **Clean Up**: Always clean up test artifacts and state
5. **Mock External Dependencies**: Don't rely on external systems in unit tests
6. **Test Edge Cases**: Include tests for error conditions and boundary values
7. **Keep Tests Fast**: Unit tests should run quickly
8. **Test Public Interface**: Focus on testing public functions, not implementation details

## Troubleshooting

### Tests Won't Run
- Ensure Pester is installed: `Get-Module -ListAvailable Pester`
- Check PowerShell version: `$PSVersionTable`
- Verify module imports in BeforeAll blocks

### Mock Not Working
- Ensure the function being mocked is in scope
- Check that Mock is called before the function is used
- Verify mock parameters match the actual function

### Coverage Not Generated
- Ensure code coverage is enabled in configuration
- Check that file paths in coverage configuration are correct
- Verify the module is loaded before tests run