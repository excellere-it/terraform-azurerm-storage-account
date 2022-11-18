# Azure Storage Account

Creates an Azure Storage Account
- [Azure Storage Account](#azure-storage-account)
  - [Example](#example)
  - [Required Inputs](#required-inputs)
    - [<a name="input_log_analytics_workspace_id"></a> log\_analytics\_workspace\_id](#-log_analytics_workspace_id)
    - [<a name="input_name"></a> name](#-name)
    - [<a name="input_resource_group"></a> resource\_group](#-resource_group)
  - [Optional Inputs](#optional-inputs)
    - [<a name="input_expiration_days"></a> expiration\_days](#-expiration_days)
    - [<a name="input_optional_tags"></a> optional\_tags](#-optional_tags)
  - [Outputs](#outputs)
    - [<a name="output_storage_account_id"></a> storage\_account\_id](#-storage_account_id)
  - [Resources](#resources)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
    - [<a name="module_diagnostics"></a> diagnostics](#-diagnostics)
    - [<a name="module_name"></a> name](#-name-1)
  - [Update Docs](#update-docs)

<!-- BEGIN_TF_DOCS -->

## Example

```hcl
locals {
  test_namespace = random_pet.instance_id.id
}

resource "random_pet" "instance_id" {}

resource "azurerm_resource_group" "example" {
  location = "centralus"
  name     = "rg-${local.test_namespace}"
  tags     = module.name.tags
}

resource "azurerm_log_analytics_workspace" "example" {
  location            = azurerm_resource_group.example.location
  name                = "la-${local.test_namespace}"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
  tags                = module.name.tags
}

module "example" {
  source = "../.."

  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  resource_group             = azurerm_resource_group.example

  name = {
    contact     = "nobody@dell.org"
    environment = "sbx"
    instance    = 0
    program     = "dyl"
    repository  = "terraform-azurerm-storage-account"
    workload    = "apps"
  }
}
```

## Required Inputs

The following input variables are required:

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: The workspace to write logs into.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name tokens used to construct the resource name and tags.

Type:

```hcl
object({
    contact     = string
    environment = string
    instance    = optional(number)
    program     = optional(string)
    repository  = string
    workload    = string
  })
```

### <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group)

Description: The resource group to deploy resources into

Type:

```hcl
object({
    location = string
    name     = string
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_expiration_days"></a> [expiration\_days](#input\_expiration\_days)

Description: Used to calculate the value of the EndDate tag by adding the specified number of days to the CreateDate tag.

Type: `number`

Default: `365`

### <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags)

Description: A map of additional tags for the resource.

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id)

Description: Storage Account ID.

## Resources

The following resources are used by this module:

- [azurerm_storage_account.sa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) (resource)

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.3.3)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.31)

- <a name="requirement_time"></a> [time](#requirement\_time) (~> 0.9)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 3.31)

## Modules

The following Modules are called:

### <a name="module_diagnostics"></a> [diagnostics](#module\_diagnostics)

Source: app.terraform.io/dellfoundation/diagnostics/azurerm

Version: 0.0.3

### <a name="module_name"></a> [name](#module\_name)

Source: app.terraform.io/dellfoundation/namer/terraform

Version: 0.0.2
<!-- END_TF_DOCS -->

## Update Docs

Run this command:

```
terraform-docs markdown document --output-file README.md --output-mode inject .
```