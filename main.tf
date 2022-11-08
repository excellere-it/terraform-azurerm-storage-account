locals {
  name = join("-", compact(["rg", var.name.workload, var.name.environment, var.location, var.name.program, var.name.instance]))
  tags = merge(local.default_tags, var.required_tags, var.optional_tags)

  default_tags = {
    CreateDate = formatdate("YYYY-MM-DD", time_static.create_date.rfc3339)
    EndDate    = formatdate("YYYY-MM-DD", time_offset.end_date.rfc3339)
    Source     = "IAC"
  }
}

resource "time_static" "create_date" {}

resource "time_offset" "end_date" {
  base_rfc3339 = time_static.create_date.id
  offset_years = var.expiration_years
}

resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = local.name
  tags     = local.tags
}
