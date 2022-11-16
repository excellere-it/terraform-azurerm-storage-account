# Azure Storage Account

Creates an Azure Storage Account
- [Storage Account](#azure-storage-account)
    - [Example](#example)
    - [Required Inputs](#required-inputs)
    - [Optional Inputs](#optional-inputs)
    - [Outputs](#outputs)
    - [Resources](#resources)
    - [Requirements](#requirements)
    - [Providers](#providers)
    - [Modules](#modules)
    - [Update Docs](#update-docs)

<!-- BEGIN_TF_DOCS -->


## Example

```hcl
locals {
  test_namespace = random_pet.instance_id.id

  name = {
    contact     = "nobody@dell.org"
    environment = "sbx"
    program     = "dyl"
    repository  = "terraform-azurerm-key-vault"
    workload    = "apps"
  }
}

module "name" {
  source  = "app.terraform.io/dellfoundation/namer/terraform"
  version = "0.0.2"

  contact     = local.name.contact
  environment = local.name.environment
  location    = "centralus"
  program     = local.name.program
  repository  = local.name.repository
  workload    = local.name.workload
}

resource "random_pet" "instance_id" {}

resource "azurerm_resource_group" "example" {
  location = "centralus"
  name     = "rg-${local.test_namespace}"
  tags     = module.name.tags
}

module "example" {
  source = "../.."

  location       = azurerm_resource_group.example.location
  resource_group = azurerm_resource_group.example

  name = {
    contact     = "nobody@dell.org"
    environment = "sbx"
    program     = "dyl"
    repository  = "terraform-azurerm-storage-account"
    workload    = "apps"
  }
}
```

## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: The Azure Region to deploy the resource into.

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

### <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags)

Description: A map of additional tags for the resource.

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_storage_account"></a> [storage\_account](#output\_storage\_account)

Description: All of the Storage Account attributes.

## Resources

The following resources are used by this module:

- [azurerm_storage_account.sa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) (resource)

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.3.3)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.28.0)

- <a name="requirement_time"></a> [time](#requirement\_time) (~> 0.9.1)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 3.28.0)

## Modules

The following Modules are called:

### <a name="module_name"></a> [name](#module\_name)

Source: app.terraform.io/dellfoundation/namer/terraform

Version: 0.0.2
<!-- END_TF_DOCS -->

## Update Docs

Run this command:

```
terraform-docs markdown document --output-file README.md --output-mode inject .
```