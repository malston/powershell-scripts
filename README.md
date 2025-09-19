# PowerShell Scripts Repository

A well-organized collection of PowerShell scripts and modules following industry best practices, with full cross-platform support.

## 🚀 Quick Start

```powershell
# Clone the repository
git clone https://github.com/malston/powershell-scripts.git
cd powershell-scripts

# Import the module
Import-Module .\modules\MyModule\MyModule.psd1

# Run a sample script
.\scripts\administration\Get-SystemInfo.ps1
```

## 📚 Documentation

- **[Installation Guide](docs/INSTALLATION.md)** - Setup instructions and prerequisites
- **[Modules Documentation](docs/MODULES.md)** - Available modules and functions
- **[Scripts Documentation](docs/SCRIPTS.md)** - Standalone scripts reference
- **[Testing Guide](docs/TESTING.md)** - How to run and write tests
- **[Development Guide](docs/DEVELOPMENT.md)** - Contributing code and best practices
- **[Contributing](docs/CONTRIBUTING.md)** - How to contribute to the project
- **[Changelog](CHANGELOG.md)** - Version history and release notes

## 📁 Project Structure

```sh
powershell-scripts/
├── modules/           # PowerShell modules
│   └── MyModule/     # Example module with functions
├── scripts/          # Standalone scripts
│   └── administration/   # System administration scripts
├── tests/            # Pester test files
├── tools/            # Build and deployment tools
├── docs/             # Documentation
└── .vscode/          # VS Code configuration
```

## ✨ Features

- ✅ **Cross-platform** - Works on Windows, macOS, and Linux
- ✅ **VS Code Integration** - Pre-configured for PowerShell development
- ✅ **Testing Framework** - Comprehensive Pester tests
- ✅ **Build Automation** - Automated build and deployment
- ✅ **Best Practices** - Follows PowerShell community guidelines
- ✅ **Documentation** - Extensive help and examples

## 🛠️ Available Tools

### Modules

- **MyModule** - Core module with Get/Set/Test/New functions

### Scripts

- **Get-SystemInfo** - Cross-platform system information gathering
- **Get-SystemInfo-Windows** - Windows-specific with advanced features

## 🧪 Testing

```powershell
# Run all tests
Invoke-Pester .\tests\

# Run with coverage
Invoke-Pester .\tests\ -CodeCoverage .\modules\**\*.ps1
```

## 🔧 Requirements

- PowerShell 5.1+ or PowerShell Core 7+
- Git (for version control)
- Pester 5.0+ (for testing)
- VS Code with PowerShell extension (recommended)

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](docs/CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📊 Status

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

## 🙏 Acknowledgments

Built with PowerShell best practices and community standards in mind.

---

**[Get Started →](docs/INSTALLATION.md)**
