# Azure App Service

Creates an Azure App Service (Windows)

<!-- BEGIN_TF_DOCS -->


## Example

```hcl
module "example" {
  source = "../.."

  location = "centralus"

  # The following tokens are optional: instance, program
  name = {
    workload    = "apps"
    instance    = 0
    environment = "sbx"
    program     = "dyl"
  }

  # Program is optional. To meet compliance requirements, the module uses "Shared" when the tag is omitted.
  required_tags = {
    Contact    = "nobody@dell.org"
    Program    = "DYL"
    Repository = "terraform-azurerm-resource-group"
  }
}
```

## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: The Azure Region to deploy the resource into.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name tokens used to construct the resource name.

Type:

```hcl
object({
    environment = string
    instance    = optional(number)
    program     = optional(string)
    workload    = string
  })
```

### <a name="input_required_tags"></a> [required\_tags](#input\_required\_tags)

Description: A map of tags required to meet the tag compliance policy.

Type:

```hcl
object({
    Contact    = string
    Program    = optional(string, "Shared")
    Repository = string
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_expiration_years"></a> [expiration\_years](#input\_expiration\_years)

Description: Used to calculate the value of the EndDate tag by adding the specified number of years to the CreateDate tag.

Type: `number`

Default: `1`

### <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags)

Description: A map of additional tags for the resource.

Type: `map(string)`

Default: `{}`

## Outputs

No outputs.

## Resources

The following resources are used by this module:

- [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [time_offset.end_date](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/offset) (resource)
- [time_static.create_date](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/static) (resource)

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.3.3)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.28.0)

- <a name="requirement_time"></a> [time](#requirement\_time) (~> 0.9.1)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 3.28.0)

- <a name="provider_time"></a> [time](#provider\_time) (~> 0.9.1)

## Modules

No modules.
<!-- END_TF_DOCS -->

## Update Docs

Run this command:

```
terraform-docs markdown document --output-file README.md --output-mode inject .
```