# Terraform Tests

This directory contains native Terraform tests for the storage account module.

## Overview

The tests use Terraform's built-in testing framework (introduced in Terraform 1.6.0) to validate module functionality, input validation, and output correctness.

## Test Files

### basic.tftest.hcl

Core functionality tests that verify:
- Module can be instantiated with valid inputs
- Storage account is created successfully
- Outputs are generated correctly
- Basic resource configurations are applied

### validation.tftest.hcl

Input validation tests that verify:
- Invalid inputs are rejected with appropriate error messages
- Variable validation rules work correctly
- Edge cases are handled properly

## Running Tests

### Run All Tests

```bash
# Using Make
make test-terraform

# Using Terraform directly
terraform test -verbose
```

### Run Specific Test File

```bash
# Using Make
make test-terraform-filter FILE=tests/basic.tftest.hcl

# Using Terraform directly
terraform test -filter=tests/basic.tftest.hcl -verbose
```

### Run Specific Test Case

```bash
terraform test -filter=tests/basic.tftest.hcl -verbose -var="test_name=test_basic_storage_account"
```

## Test Structure

Each test file follows this structure:

```hcl
# Test configuration
run "test_name" {
  command = plan  # or apply

  variables {
    # Test-specific variables
  }

  assert {
    condition     = <boolean expression>
    error_message = "Descriptive error message"
  }

  # For validation tests expecting failure
  expect_failures = [
    var.variable_name
  ]
}
```

## Writing New Tests

### Test Naming Convention

- Use descriptive names: `test_<feature>_<scenario>`
- Examples:
  - `test_storage_account_creation`
  - `test_invalid_sku_rejected`
  - `test_containers_created`

### Test Best Practices

1. **One assertion per test** when possible
2. **Clear error messages** that explain what went wrong
3. **Test both success and failure** scenarios
4. **Use realistic test data** but keep it simple
5. **Clean up resources** (use `command = plan` when possible)

### Example Test

```hcl
run "test_storage_account_has_correct_sku" {
  command = plan

  variables {
    resource_group = {
      name     = "rg-test"
      location = "centralus"
    }
    sku = "GRS"
    # ... other required variables
  }

  assert {
    condition     = azurerm_storage_account.sa.account_replication_type == "GRS"
    error_message = "Storage account SKU should be GRS"
  }
}
```

## Test Coverage

Current test coverage includes:

- [x] Basic storage account creation
- [x] Input validation for required variables
- [x] SKU validation
- [x] Container creation
- [x] File share creation
- [x] Network rules configuration
- [x] Private endpoint integration

## Troubleshooting

### Test Fails with "Provider not found"

**Solution:** Initialize Terraform before running tests

```bash
terraform init
terraform test
```

### Test Fails with "Missing required argument"

**Solution:** Check that all required variables are provided in the test

### Test Takes Too Long

**Solution:** Use `command = plan` instead of `command = apply` when possible

### Can't Debug Test Failure

**Solution:** Run test with verbose output

```bash
terraform test -verbose
```

## Comparison with Go Tests

This module has both Terraform native tests and Go-based tests:

| Aspect | Terraform Tests | Go Tests (Terratest) |
|--------|----------------|----------------------|
| **Location** | `tests/` | `test/` |
| **Language** | HCL | Go |
| **Speed** | Fast (plan only) | Slower (real resources) |
| **Coverage** | Unit/Validation | Integration |
| **Setup** | Terraform only | Go + Terraform |
| **Use Case** | Quick validation | Full deployment testing |

### When to Use Each

**Use Terraform Tests:**
- Validating input constraints
- Testing output generation
- Quick feedback during development
- CI/CD validation checks

**Use Go Tests:**
- Integration testing with real Azure resources
- End-to-end scenarios
- Testing actual resource behavior
- Validating cloud interactions

## Related Documentation

- [Terraform Testing](https://developer.hashicorp.com/terraform/language/tests)
- [Writing Terraform Tests](https://developer.hashicorp.com/terraform/tutorials/configuration-language/test)
- [Terratest](https://terratest.gruntwork.io/)

## Contributing

When adding new features to the module:

1. Add corresponding tests in `tests/`
2. Ensure tests pass locally
3. Update this README if adding new test files
4. Follow existing test patterns and conventions

## Contact

For questions about tests or to report issues, please create an issue in the repository.
