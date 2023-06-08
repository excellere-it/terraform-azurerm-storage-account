# Azure Storage Account

Creates an Azure Storage Account
- [Azure Storage Account](#azure-storage-account)
  - [Example](#example)
  - [Required Inputs](#required-inputs)
    - [ action\_group\_id](#-action_group_id)
    - [ log\_analytics\_workspace\_id](#-log_analytics_workspace_id)
    - [ name](#-name)
    - [ private\_endpoint](#-private_endpoint)
    - [ resource\_group](#-resource_group)
  - [Optional Inputs](#optional-inputs)
    - [ containers](#-containers)
    - [ expiration\_days](#-expiration_days)
    - [ optional\_tags](#-optional_tags)
    - [ shares](#-shares)
    - [ testing](#-testing)
  - [Outputs](#outputs)
    - [ id](#-id)
    - [ name](#-name-1)
    - [ primary\_access\_key](#-primary_access_key)
  - [Resources](#resources)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
    - [ diagnostics](#-diagnostics)
    - [ name](#-name-2)
    - [ private\_endpoint](#-private_endpoint-1)
  - [Update Docs](#update-docs)

<!-- BEGIN_TF_DOCS -->


## Example

```hcl
locals {
  location       = "centralus"
  tags           = module.name.tags
  test_namespace = random_pet.instance_id.id
}

resource "azurerm_log_analytics_workspace" "example" {
  location            = azurerm_resource_group.example.location
  name                = "la-${local.test_namespace}"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
  tags                = local.tags
}

resource "azurerm_monitor_action_group" "example" {
  name                = "CriticalAlertsAction"
  resource_group_name = azurerm_resource_group.example.name
  short_name          = "p0action"
  tags                = local.tags
}

resource "azurerm_resource_group" "example" {
  location = local.location
  name     = "rg-${local.test_namespace}"
  tags     = local.tags
}

resource "azurerm_virtual_network" "example" {
  address_space       = ["192.168.0.0/24"]
  location            = azurerm_resource_group.example.location
  name                = "vnet-${local.test_namespace}"
  resource_group_name = azurerm_resource_group.example.name
  tags                = local.tags
}

resource "azurerm_subnet" "example" {
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.example.address_space.0, 1, 0)]
  name                 = "storage"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
}

resource "azurerm_private_dns_zone" "example" {
  for_each = {
    blob = "privatelink.blob.core.windows.net"
    file = "privatelink.file.core.windows.net"
  }

  name                = each.value
  resource_group_name = azurerm_resource_group.example.name
  tags                = local.tags
}


resource "random_pet" "instance_id" {}

module "example" {
  source = "../.."

  action_group_id            = azurerm_monitor_action_group.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  resource_group             = azurerm_resource_group.example
  testing                    = true

  containers = [
    "sqlreports"
  ]

  name = {
    contact     = "nobody@dell.org"
    environment = "sbx"
    instance    = 0
    program     = "dyl"
    repository  = "terraform-azurerm-storage-account"
    workload    = "apps"
  }

  private_endpoint = {
    enabled     = true
    subnet_id   = azurerm_subnet.example.id
    subresource = { for k, v in azurerm_private_dns_zone.example : k => [v.id] }
  }

  shares = [
    "university-success"
  ]
}
```

## Required Inputs

The following input variables are required:

### <a name="input_action_group_id"></a> [action\_group\_id](#input\_action\_group\_id)

Description: The ID of the action group to send alerts to.

Type: `string`

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

### <a name="input_containers"></a> [containers](#input\_containers)

Description: When provided the module will create private blob containers for each item in the list.

Type: `list(string)`

Default: `[]`

### <a name="input_expiration_days"></a> [expiration\_days](#input\_expiration\_days)

Description: Used to calculate the value of the EndDate tag by adding the specified number of days to the CreateDate tag.

Type: `number`

Default: `365`

### <a name="input_ip_restriction"></a> [ip\_restriction](#input\_ip\_restriction)

Description: The IP restriction configuration.

Type:

```hcl
object({
    enabled = bool
    ip = optional(map(object({
      ip_address = string
      name       = string
    })))
  })
```

Default:

```json
{
  "enabled": false
}
```

### <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags)

Description: A map of additional tags for the resource.

Type: `map(string)`

Default: `{}`

### <a name="input_private_endpoint"></a> [private\_endpoint](#input\_private\_endpoint)

Description: The private endpoint configuration.

Type:

```hcl
object({
    enabled     = bool
    subnet_id   = optional(string)
    subresource = optional(map(list(string)))
  })
```

Default:

```json
{
  "enabled": false
}
```

### <a name="input_shares"></a> [shares](#input\_shares)

Description: When provided the module will create file shares for each item in the list.

Type: `list(string)`

Default: `[]`

### <a name="input_testing"></a> [testing](#input\_testing)

Description: When true the module will use the testing options; for example public access will be enabled.

Type: `bool`

Default: `false`

## Outputs

The following outputs are exported:

### <a name="output_containers"></a> [containers](#output\_containers)

Description: The storage account containers.

### <a name="output_id"></a> [id](#output\_id)

Description: Storage Account ID.

### <a name="output_name"></a> [name](#output\_name)

Description: The storage account name.

### <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key)

Description: The storage account primary access key.

### <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint)

Description: The storage account primary blob endpoint.

### <a name="output_primary_connection_string"></a> [primary\_connection\_string](#output\_primary\_connection\_string)

Description: The storage account primary connection string.

## Resources

The following resources are used by this module:

- [azurerm_monitor_metric_alert.alert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) (resource)
- [azurerm_storage_account.sa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) (resource)
- [azurerm_storage_container.container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) (resource)
- [azurerm_storage_share.share](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) (resource)

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.3)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.41)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 3.41)

## Modules

The following Modules are called:

### <a name="module_diagnostics"></a> [diagnostics](#module\_diagnostics)

Source: app.terraform.io/dellfoundation/diagnostics/azurerm

Version: 0.0.10

### <a name="module_name"></a> [name](#module\_name)

Source: app.terraform.io/dellfoundation/namer/terraform

Version: 0.0.7

### <a name="module_private_endpoint"></a> [private\_endpoint](#module\_private\_endpoint)

Source: app.terraform.io/dellfoundation/private-link/azurerm

Version: 0.0.4
<!-- END_TF_DOCS -->

## Update Docs

Run this command:

```
terraform-docs markdown document --output-file README.md --output-mode inject .
```