# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive .gitignore with extensive patterns for development environments
- Enhanced Makefile with full development workflow automation
- CONTRIBUTING.md with development workflow and guidelines
- CHANGELOG.md for tracking version history
- Native Terraform tests in tests/ directory
- GitHub Actions test workflow for comprehensive CI/CD
- GitHub Actions release workflow
- Workflow documentation in .github/workflows/README.md

### Changed
- Improved documentation structure and generation
- Enhanced module development workflow

## [0.0.4] - Previous Release

### Added
- Storage account creation with secure defaults
- Support for blob containers and file shares
- Private endpoint integration
- Azure Monitor metric alerts for availability
- Diagnostic logging to Log Analytics workspace
- Backup protection for file shares
- Network security rules with IP restrictions
- Blob versioning and retention policies
- System-assigned managed identity
- Support for multiple storage redundancy options (RAGZRS, etc.)

### Supported
- Terraform >= 1.5
- Azure Provider >= 3.41
- Storage account types: Standard
- Replication types: RAGZRS, GRS, LRS, ZRS

### Features
- Automatic naming using namer module
- Tag standardization
- Configurable retention policies (30 days)
- HTTPS-only traffic enforcement
- Infrastructure encryption enabled
- Minimum TLS version 1.2
- Testing mode for development

---

## Version History Notes

### Versioning Scheme

This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR** version for incompatible API changes
- **MINOR** version for new functionality in a backward compatible manner
- **PATCH** version for backward compatible bug fixes

### Release Process

Releases are automated via GitHub Actions:
1. Create a tag matching the pattern `0.0.*` (e.g., `0.0.5`)
2. Push the tag to GitHub
3. GitHub Actions automatically creates a release with notes

### Upgrade Guidance

When upgrading between versions, check the relevant sections above for:
- **Breaking Changes**: May require updates to your configuration
- **Deprecated Features**: Plan to migrate away from these
- **New Features**: Optional enhancements you may want to adopt

---

## Template for Future Releases

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New features and capabilities

### Changed
- Changes to existing functionality

### Deprecated
- Features that will be removed in future versions

### Removed
- Features removed in this version

### Fixed
- Bug fixes

### Security
- Security-related changes
```

---

[Unreleased]: https://github.com/infoex/terraform-azurerm-storage-account/compare/0.0.4...HEAD
[0.0.4]: https://github.com/infoex/terraform-azurerm-storage-account/releases/tag/0.0.4
