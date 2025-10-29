# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.4] - 2025-10-29

### Fixed
- Fixed private_endpoint module call to match private-link v0.0.2 interface
  - Added required `name` object with terraform-namer inputs
  - Changed `tags` to `optional_tags` parameter
  - Removed unsupported `resource_prefix` argument
- Resolved terraform plan failures: "Missing required argument: name", "Unsupported argument: resource_prefix", "Unsupported argument: tags"

## [0.0.3] - 2025-10-29

### Added
- Comprehensive .gitignore with extensive patterns for development environments
- Enhanced Makefile with full development workflow automation
- CONTRIBUTING.md with development workflow and guidelines
- CHANGELOG.md for tracking version history
- Native Terraform tests in tests/ directory
- GitHub Actions test workflow for comprehensive CI/CD
- GitHub Actions release workflow
- Workflow documentation in .github/workflows/README.md
- Comprehensive module header documentation (80+ lines) in main.tf
- Section headers for improved code organization in all files
- New `public_network_access_enabled` variable for explicit public access control
- Additional test cases for optional monitoring and backup features
- `shares` output for accessing created file shares

### Changed
- **BREAKING**: Refactored terraform-namer integration to use direct inputs (`contact`, `environment`, `location`, `repository`, `workload`) instead of `name` object
- **BREAKING**: Made `action_group_id` optional (default: null) - monitoring alerts now optional
- **BREAKING**: Made `backup_policy_id` optional (default: null) - backup protection now optional
- **BREAKING**: Made `recovery_vault` optional (default: null) - only required when backup is enabled
- Updated private-link module dependency to version 0.0.2
- Improved variable descriptions and organization with logical grouping
- Enhanced output descriptions for better clarity
- Updated all examples to use new variable structure
- Improved test coverage with optional feature testing

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
[0.0.4]: https://github.com/infoex/terraform-azurerm-storage-account/compare/0.0.3...0.0.4
[0.0.3]: https://github.com/infoex/terraform-azurerm-storage-account/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/infoex/terraform-azurerm-storage-account/releases/tag/0.0.2
