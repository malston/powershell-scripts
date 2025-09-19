# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Cross-platform support for Get-SystemInfo script
- VS Code integration with tasks and debugging
- Comprehensive documentation structure split into separate files
- Set-Something, Test-Something, and New-Something module functions
- QUICKSTART.md for VS Code users
- .gitignore file for PowerShell projects

### Changed
- Renamed Get-SystemInfo.ps1 to work cross-platform by default
- Original Windows-specific version renamed to Get-SystemInfo-Windows.ps1
- Reorganized documentation into docs/ directory
- README.md simplified with links to detailed documentation

### Fixed
- PowerShell Core compatibility issues with environment variables
- Test-Connection compatibility on macOS/Linux
- Cross-platform $env:COMPUTERNAME handling

## [1.0.0] - 2025-01-01

### Added

- Initial release of PowerShell repository structure
- MyModule with core functionality:
  - Get-Something function for retrieving system information
  - Private helper functions for logging and validation
  - Comprehensive comment-based help
- Administration scripts:
  - Get-SystemInfo.ps1 for gathering system information
- Testing framework:
  - Pester tests for all public functions
  - Code coverage reporting
  - Continuous integration with GitHub Actions
- Documentation:
  - Comprehensive README with usage examples
  - Code templates and best practices guide
  - Contributing guidelines
- Development tools:
  - PowerShell script analyzer configuration
  - Git ignore templates for PowerShell projects
  - GitHub Actions workflow for automated testing
- Repository structure following PowerShell best practices:
  - Modules organized with public/private function separation
  - Scripts categorized by purpose (administration, automation, utilities)
  - Proper module manifests with metadata
  - Example files demonstrating conventions

### Security

- Input validation for all public functions
- Secure credential handling examples
- No hardcoded sensitive information

---

## Release Notes Format

Each release should include:

### Added

- New features and functionality
- New scripts or modules
- New documentation

### Changed

- Changes to existing functionality
- Updates to documentation
- Improvements to performance

### Deprecated

- Features that will be removed in future versions
- Legacy functions or parameters

### Removed

- Features that have been removed
- Discontinued scripts or modules

### Fixed

- Bug fixes
- Corrections to documentation
- Performance improvements

### Security

- Security-related changes
- Vulnerability fixes
- Credential handling improvements

---

## Version Numbering

This project uses Semantic Versioning (SemVer):

- **MAJOR** version: Incompatible API changes
- **MINOR** version: New functionality (backwards compatible)
- **PATCH** version: Bug fixes (backwards compatible)

### Examples

- `1.0.0` → `1.0.1`: Bug fix
- `1.0.1` → `1.1.0`: New feature added
- `1.1.0` → `2.0.0`: Breaking change

---

## How to Update This Changelog

1. Keep the changelog up to date with every significant change
2. Add entries under the "Unreleased" section during development
3. When creating a release:
   - Move "Unreleased" items to a new version section
   - Add the release date
   - Create a new empty "Unreleased" section
4. Use clear, descriptive language
5. Group changes by type (Added, Changed, etc.)
6. Include issue numbers when applicable: `Fixed login timeout issue (#123)`

---

## Links

- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)
- [PowerShell Gallery](https://www.powershellgallery.com/)
