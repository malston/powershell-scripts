# MyModule.psm1
# Main module file that imports all public and private functions

# Get public and private function definition files
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# Import all public and private functions
foreach ($import in @($Public + $Private)) {
    try {
        Write-Verbose "Importing $($import.FullName)"
        . $import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($import.FullName): $($_.Exception.Message)"
    }
}

# Export only the public functions
Export-ModuleMember -Function $Public.BaseName

# Module initialization code (if needed)
Write-Verbose "MyModule loaded successfully"

# Optional: Set module-level variables
$ModuleRoot = $PSScriptRoot
Export-ModuleMember -Variable ModuleRoot
