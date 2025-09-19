# Contributing Guide

Thank you for your interest in contributing to this PowerShell project! This guide will help you get started.

## Code of Conduct

Please be respectful and considerate in all interactions. We're here to collaborate and improve the project together.

## How to Contribute

### Reporting Issues

1. Check if the issue already exists
2. Include PowerShell version (`$PSVersionTable`)
3. Provide minimal reproduction steps
4. Include error messages and stack traces
5. Specify your operating system

### Suggesting Features

1. Open an issue with the "enhancement" label
2. Describe the use case
3. Provide examples of how it would work
4. Consider backwards compatibility

### Submitting Pull Requests

#### Setup

1. Fork the repository
2. Clone your fork
   ```powershell
   git clone https://github.com/yourusername/powershell-scripts.git
   cd powershell-scripts
   ```

3. Create a feature branch
   ```powershell
   git checkout -b feature/your-feature-name
   ```

#### Development Process

1. **Make your changes**
   - Follow the [Development Guide](DEVELOPMENT.md)
   - Add/update tests as needed
   - Update documentation

2. **Test your changes**
   ```powershell
   # Run tests
   Invoke-Pester .\tests\

   # Run script analyzer
   Invoke-ScriptAnalyzer -Path . -Recurse

   # Test the build
   .\tools\build.ps1 -Task All
   ```

3. **Commit your changes**
   ```powershell
   git add .
   git commit -m "feat(scope): description of change"
   ```

4. **Push to your fork**
   ```powershell
   git push origin feature/your-feature-name
   ```

5. **Create Pull Request**
   - Go to GitHub and create a PR from your fork
   - Fill out the PR template
   - Link any related issues

## Pull Request Guidelines

### PR Requirements

- [ ] All tests pass
- [ ] No PSScriptAnalyzer warnings
- [ ] Documentation updated
- [ ] Follows code style guidelines
- [ ] Includes tests for new functionality
- [ ] Commit messages follow convention

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Refactoring

## Testing
- [ ] Tested on Windows
- [ ] Tested on macOS
- [ ] Tested on Linux

## Related Issues
Fixes #123

## Additional Notes
Any additional information
```

## Development Guidelines

### Code Quality

1. **Write Clean Code**
   - Clear variable names
   - Single responsibility functions
   - Proper error handling
   - Comprehensive comments

2. **Follow PowerShell Conventions**
   - Use approved verbs
   - PascalCase for functions
   - Include help documentation
   - Support pipeline when appropriate

3. **Test Coverage**
   - Write unit tests for new functions
   - Maintain or improve coverage
   - Test error conditions
   - Include integration tests when needed

### Documentation

1. **Code Documentation**
   - Comment-based help for all functions
   - Inline comments for complex logic
   - Examples in help documentation

2. **User Documentation**
   - Update relevant .md files
   - Include usage examples
   - Document breaking changes
   - Update README if needed

## Review Process

1. **Automated Checks**
   - Tests must pass
   - Code analysis must pass
   - No merge conflicts

2. **Code Review**
   - At least one maintainer review
   - Address feedback promptly
   - Discussion on implementation

3. **Merge**
   - Squash and merge for features
   - Conventional commit message
   - Delete branch after merge

## Release Process

### Version Numbering

We follow Semantic Versioning (MAJOR.MINOR.PATCH):
- MAJOR: Breaking changes
- MINOR: New features (backwards compatible)
- PATCH: Bug fixes

### Release Checklist

1. Update version in module manifest
2. Update CHANGELOG.md
3. Run full test suite
4. Create GitHub release
5. Publish to PowerShell Gallery (if applicable)

## Getting Help

- Open an issue for questions
- Check existing documentation
- Review closed issues and PRs
- Ask in discussions

## Recognition

Contributors will be recognized in:
- CHANGELOG.md
- GitHub contributors page
- Release notes

Thank you for contributing!