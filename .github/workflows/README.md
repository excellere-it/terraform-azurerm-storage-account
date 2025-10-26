# GitHub Actions Workflows

This directory contains GitHub Actions workflows for automated testing and release management.

## Workflows

### test.yml

The main testing workflow that runs on every push and pull request.

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches
- Manual workflow dispatch
- Only runs when `*.tf`, `test/**`, or workflow files change

**Jobs:**

1. **terraform-format** - Checks Terraform code formatting
   - Uses `terraform fmt -check -recursive`
   - Fails if code is not properly formatted

2. **terraform-validate** - Validates Terraform configuration
   - Runs `terraform init -backend=false`
   - Runs `terraform validate`

3. **security-scan** - Security scanning with Checkov
   - Scans for security issues and misconfigurations
   - Runs in soft-fail mode (warnings don't fail the build)
   - Uploads SARIF results as artifacts

4. **lint** - Code quality linting with TFLint
   - Initializes and runs TFLint
   - Checks for best practices and potential errors

5. **test-examples** - Tests all example configurations
   - Runs in matrix strategy for each example (default, no-ple)
   - Initializes, validates, and plans each example
   - Uploads plan artifacts

6. **test-summary** - Aggregates test results
   - Creates a summary in GitHub Actions
   - Fails if required tests fail

7. **comment-pr** - Comments on pull requests
   - Posts test results summary to PR
   - Shows status icons for each check

**Required Secrets:**
None - this workflow doesn't require any secrets

**Permissions:**
- `contents: read` - Read repository contents
- `pull-requests: write` - Comment on pull requests

### release-module.yml

Automated release creation workflow.

**Triggers:**
- Tags matching pattern `0.0.*`

**Actions:**
- Creates GitHub release
- Auto-generates release notes from commits

**Required Secrets:**
None - uses GitHub token automatically

## Running Workflows Locally

### Prerequisites

Install [act](https://github.com/nektos/act) to run GitHub Actions locally:

```bash
# macOS
brew install act

# Linux
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Windows
choco install act-cli
```

### Run Tests Locally

```bash
# Run all jobs
act -j terraform-format -j terraform-validate

# Run specific job
act -j terraform-format

# Run pull request event
act pull_request
```

## Workflow Troubleshooting

### Common Issues

#### 1. Format Check Fails

**Problem:** `terraform fmt -check` fails

**Solution:** Run `make fmt` locally before pushing

```bash
make fmt
git add .
git commit --amend --no-edit
git push --force
```

#### 2. Validation Fails

**Problem:** `terraform validate` fails

**Solution:** Check for syntax errors and run validation locally

```bash
terraform init -backend=false
terraform validate
```

#### 3. Example Tests Fail

**Problem:** Example initialization or planning fails

**Solution:** Test the example locally

```bash
cd examples/default
terraform init
terraform validate
terraform plan
```

#### 4. Security Scan Warnings

**Problem:** Checkov reports security issues

**Solution:** Review the security findings and either:
- Fix the issues
- Add exception comments if findings are false positives

```hcl
#checkov:skip=CKV_AZURE_123:Reason for skipping
resource "azurerm_storage_account" "example" {
  # ...
}
```

#### 5. Lint Warnings

**Problem:** TFLint reports style issues

**Solution:** Review and fix the linting issues

```bash
make lint
```

### Updating Workflows

When modifying workflows:

1. Test changes in a feature branch
2. Use `workflow_dispatch` trigger for manual testing
3. Review workflow runs in GitHub Actions tab
4. Check both success and failure scenarios

## Workflow Configuration

### Terraform Version

Workflows use Terraform version `1.5.0`. To update:

1. Change `terraform_version` in workflow file
2. Update `versions.tf` in module
3. Test all examples with new version

### Example Matrix

The `test-examples` job uses a matrix strategy. To add/remove examples:

```yaml
strategy:
  matrix:
    example:
      - default
      - no-ple
      - your-new-example  # Add here
```

### Timeout Settings

Default timeout is 6 hours. To adjust:

```yaml
jobs:
  job-name:
    timeout-minutes: 30
```

## Best Practices

1. **Always test locally** before pushing
2. **Run `make fmt`** to ensure formatting
3. **Run `make validate`** to check configuration
4. **Update examples** when changing module interface
5. **Check workflow runs** after pushing
6. **Review security findings** seriously
7. **Keep workflows up to date** with latest actions versions

## Related Documentation

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform GitHub Actions](https://github.com/hashicorp/setup-terraform)
- [Checkov Documentation](https://www.checkov.io/)
- [TFLint Documentation](https://github.com/terraform-linters/tflint)

## Contact

For workflow issues or questions, please create an issue in the repository.
