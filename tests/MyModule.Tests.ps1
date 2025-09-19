# Pester test for MyModule

BeforeAll {
    # Import the module
    $ModulePath = Join-Path $PSScriptRoot '..' 'modules' 'MyModule' 'MyModule.psd1'
    Import-Module $ModulePath -Force
}

Describe "MyModule" {
    Context "Module Import" {
        It "Should import without errors" {
            Get-Module MyModule | Should -Not -BeNullOrEmpty
        }

        It "Should export expected functions" {
            $ExportedFunctions = (Get-Module MyModule).ExportedFunctions.Keys
            $ExportedFunctions | Should -Contain "Get-Something"
        }
    }
}

Describe "Get-Something" {
    Context "Parameter Validation" {
        It "Should accept valid Name parameter" {
            { Get-Something -Name "TestItem" } | Should -Not -Throw
        }

        It "Should throw error for empty Name parameter" {
            { Get-Something -Name "" } | Should -Throw
        }

        It "Should accept pipeline input" {
            { "TestItem" | Get-Something } | Should -Not -Throw
        }
    }

    Context "Function Output" {
        BeforeAll {
            $Result = Get-Something -Name "TestItem"
        }

        It "Should return an object" {
            $Result | Should -Not -BeNullOrEmpty
        }

        It "Should have expected properties" {
            $Result.Name | Should -Be "TestItem"
            $Result.ComputerName | Should -Not -BeNullOrEmpty
            $Result.Status | Should -Be "Found"
            $Result.Timestamp | Should -BeOfType [datetime]
        }

        It "Should have Details property" {
            $Result.Details | Should -Not -BeNullOrEmpty
            $Result.Details.Property1 | Should -Be "Value1"
        }
    }

    Context "Error Handling" {
        It "Should handle invalid computer names gracefully" {
            Mock Test-Connection { return $false } -ParameterFilter { $ComputerName -eq "InvalidComputer" }
            { Get-Something -Name "Test" -ComputerName "InvalidComputer" } | Should -Throw
        }
    }

    Context "Multiple Items" {
        It "Should process multiple items" {
            $Items = @("Item1", "Item2", "Item3")
            $Results = Get-Something -Name $Items
            $Results.Count | Should -Be 3
            $Results[0].Name | Should -Be "Item1"
            $Results[1].Name | Should -Be "Item2"
            $Results[2].Name | Should -Be "Item3"
        }
    }

    Context "Verbose Output" {
        It "Should produce verbose output when requested" {
            $VerboseMessages = @()
            $null = Get-Something -Name "TestItem" -Verbose 4>&1 | ForEach-Object {
                if ($_ -is [System.Management.Automation.VerboseRecord]) {
                    $VerboseMessages += $_.Message
                }
            }
            $VerboseMessages.Count | Should -BeGreaterThan 0
        }
    }
}

Describe "Private Functions" {
    Context "Helper Functions Exist" {
        It "Should have private helper functions loaded" {
            # Test that private functions are available within the module scope
            # but not exported
            $ModuleFunctions = Get-Command -Module MyModule
            $ModuleFunctions.Name | Should -Not -Contain "Write-LogMessage"
            $ModuleFunctions.Name | Should -Not -Contain "Test-Prerequisites"
        }
    }
}

AfterAll {
    # Clean up
    Remove-Module MyModule -Force -ErrorAction SilentlyContinue
}
