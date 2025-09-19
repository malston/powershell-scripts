# Build and Deployment Script

<#
.SYNOPSIS
    Builds and packages the PowerShell module for distribution.

.DESCRIPTION
    This script handles the build process for PowerShell modules including:
    - Running tests
    - Code analysis
    - Packaging for PowerShell Gallery
    - Version management

.PARAMETER Task
    Specifies the build task to execute.

.PARAMETER Configuration
    Build configuration (Debug or Release).

.PARAMETER OutputPath
    Path where build artifacts will be created.

.EXAMPLE
    PS C:\> .\build.ps1 -Task Build

    Runs the default build process.

.EXAMPLE
    PS C:\> .\build.ps1 -Task Test -Configuration Debug

    Runs only the test suite in debug mode.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('Clean', 'Build', 'Test', 'Package', 'Deploy', 'All')]
    [string]$Task = 'All',

    [Parameter(Mandatory = $false)]
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release',

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = (Join-Path $PSScriptRoot 'output')
)

# Build configuration
$BuildConfig = @{
    ModuleName = 'MyModule'
    ModulePath = Join-Path $PSScriptRoot '..' 'modules' 'MyModule'
    TestPath = Join-Path $PSScriptRoot '..' 'tests'
    OutputPath = $OutputPath
    Configuration = $Configuration
}

function Write-BuildMessage {
    param(
        [string]$Message,
        [string]$Level = 'Info'
    )

    $Timestamp = Get-Date -Format 'HH:mm:ss'
    $Color = switch ($Level) {
        'Info' { 'Green' }
        'Warning' { 'Yellow' }
        'Error' { 'Red' }
        default { 'White' }
    }

    Write-Host "[$Timestamp] $Message" -ForegroundColor $Color
}

function Invoke-CleanTask {
    Write-BuildMessage "Cleaning build artifacts..."

    if (Test-Path $BuildConfig.OutputPath) {
        Remove-Item $BuildConfig.OutputPath -Recurse -Force
        Write-BuildMessage "Removed output directory: $($BuildConfig.OutputPath)"
    }

    # Clean test results
    Get-ChildItem -Path $PSScriptRoot -Filter "*.xml" -Recurse | Remove-Item -Force
    Get-ChildItem -Path $PSScriptRoot -Filter "coverage.*" -Recurse | Remove-Item -Force

    Write-BuildMessage "Clean completed successfully"
}

function Invoke-BuildTask {
    Write-BuildMessage "Building module: $($BuildConfig.ModuleName)..."

    # Create output directory
    $ModuleOutputPath = Join-Path $BuildConfig.OutputPath $BuildConfig.ModuleName
    if (-not (Test-Path $ModuleOutputPath)) {
        New-Item -Path $ModuleOutputPath -ItemType Directory -Force | Out-Null
    }

    # Copy module files
    $SourcePath = $BuildConfig.ModulePath
    Copy-Item -Path "$SourcePath\*" -Destination $ModuleOutputPath -Recurse -Force

    # Update module version if this is a release build
    if ($BuildConfig.Configuration -eq 'Release') {
        $ManifestPath = Join-Path $ModuleOutputPath "$($BuildConfig.ModuleName).psd1"
        if (Test-Path $ManifestPath) {
            # You could implement version bumping logic here
            Write-BuildMessage "Module manifest: $ManifestPath"
        }
    }

    Write-BuildMessage "Build completed successfully"
}

function Invoke-TestTask {
    Write-BuildMessage "Running tests..."

    # Check if Pester is available
    if (-not (Get-Module Pester -ListAvailable)) {
        Write-BuildMessage "Installing Pester module..." -Level Warning
        Install-Module -Name Pester -Force -SkipPublisherCheck
    }

    # Configure Pester
    $PesterConfig = New-PesterConfiguration
    $PesterConfig.Run.Exit = $true
    $PesterConfig.Run.PassThru = $true
    $PesterConfig.TestResult.Enabled = $true
    $PesterConfig.TestResult.OutputPath = Join-Path $PSScriptRoot 'TestResults.xml'
    $PesterConfig.TestResult.OutputFormat = 'NUnitXml'
    $PesterConfig.CodeCoverage.Enabled = $true
    $PesterConfig.CodeCoverage.Path = Join-Path $BuildConfig.ModulePath '**/*.ps1'
    $PesterConfig.CodeCoverage.OutputPath = Join-Path $PSScriptRoot 'coverage.xml'
    $PesterConfig.CodeCoverage.OutputFormat = 'JaCoCo'

    # Run tests
    $TestResults = Invoke-Pester -Configuration $PesterConfig

    if ($TestResults.FailedCount -gt 0) {
        throw "Tests failed: $($TestResults.FailedCount) failed out of $($TestResults.TotalCount)"
    }

    Write-BuildMessage "All tests passed: $($TestResults.PassedCount)/$($TestResults.TotalCount)"
}

function Invoke-AnalysisTask {
    Write-BuildMessage "Running code analysis..."

    # Check if PSScriptAnalyzer is available
    if (-not (Get-Module PSScriptAnalyzer -ListAvailable)) {
        Write-BuildMessage "Installing PSScriptAnalyzer module..." -Level Warning
        Install-Module -Name PSScriptAnalyzer -Force
    }

    # Run analysis
    $AnalysisResults = Invoke-ScriptAnalyzer -Path $BuildConfig.ModulePath -Recurse -ReportSummary

    if ($AnalysisResults) {
        Write-BuildMessage "PSScriptAnalyzer found issues:" -Level Warning
        $AnalysisResults | Format-Table -AutoSize

        # In strict mode, treat warnings as errors
        if ($BuildConfig.Configuration -eq 'Release') {
            $ErrorCount = ($AnalysisResults | Where-Object Severity -eq 'Error').Count
            if ($ErrorCount -gt 0) {
                throw "PSScriptAnalyzer found $ErrorCount errors"
            }
        }
    } else {
        Write-BuildMessage "PSScriptAnalyzer found no issues"
    }
}

function Invoke-PackageTask {
    Write-BuildMessage "Packaging module..."

    $ModuleOutputPath = Join-Path $BuildConfig.OutputPath $BuildConfig.ModuleName

    if (-not (Test-Path $ModuleOutputPath)) {
        throw "Module build not found. Run build task first."
    }

    # Create package
    $PackagePath = Join-Path $BuildConfig.OutputPath "$($BuildConfig.ModuleName).zip"
    Compress-Archive -Path "$ModuleOutputPath\*" -DestinationPath $PackagePath -Force

    Write-BuildMessage "Package created: $PackagePath"

    # Generate NuGet package for PowerShell Gallery
    try {
        $ManifestPath = Join-Path $ModuleOutputPath "$($BuildConfig.ModuleName).psd1"
        $ModuleInfo = Test-ModuleManifest -Path $ManifestPath

        Write-BuildMessage "Module version: $($ModuleInfo.Version)"
        Write-BuildMessage "Module ready for PowerShell Gallery publishing"
    }
    catch {
        Write-BuildMessage "Warning: Could not validate module manifest: $($_.Exception.Message)" -Level Warning
    }
}

function Invoke-DeployTask {
    Write-BuildMessage "Deploying module..."

    # This is where you would implement deployment logic
    # Examples:
    # - Copy to a network share
    # - Deploy to PowerShell Gallery
    # - Update internal package repository

    if ($env:NUGET_API_KEY) {
        Write-BuildMessage "Deploying to PowerShell Gallery..."

        $ModuleOutputPath = Join-Path $BuildConfig.OutputPath $BuildConfig.ModuleName

        try {
            Publish-Module -Path $ModuleOutputPath -NuGetApiKey $env:NUGET_API_KEY -Repository PSGallery -Verbose
            Write-BuildMessage "Successfully deployed to PowerShell Gallery"
        }
        catch {
            Write-BuildMessage "Failed to deploy to PowerShell Gallery: $($_.Exception.Message)" -Level Error
            throw
        }
    } else {
        Write-BuildMessage "NUGET_API_KEY not found. Skipping PowerShell Gallery deployment." -Level Warning
    }
}

# Main execution
try {
    Write-BuildMessage "Starting build process - Task: $Task, Configuration: $Configuration"

    switch ($Task) {
        'Clean' { Invoke-CleanTask }
        'Build' { Invoke-BuildTask }
        'Test' { Invoke-TestTask }
        'Package' { Invoke-PackageTask }
        'Deploy' { Invoke-DeployTask }
        'All' {
            Invoke-CleanTask
            Invoke-BuildTask
            Invoke-AnalysisTask
            Invoke-TestTask
            Invoke-PackageTask
        }
    }

    Write-BuildMessage "Build process completed successfully"
}
catch {
    Write-BuildMessage "Build failed: $($_.Exception.Message)" -Level Error
    exit 1
}
