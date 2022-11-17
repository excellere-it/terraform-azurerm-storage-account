locals {
  test_namespace = random_pet.instance_id.id

  name = {
    contact     = "nobody@dell.org"
    environment = "sbx"
    program     = "dyl"
    repository  = "terraform-storage-account"
    workload    = "apps"
  }
}

resource "random_pet" "instance_id" {}

resource "azurerm_resource_group" "example" {
  location = "centralus"
  name     = "rg-${local.test_namespace}"
  tags     = module.name.tags
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "la-${local.test_namespace}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = module.name.tags
}

module "example" {
  source = "../.."

  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  resource_group             = azurerm_resource_group.example

  name = {
    contact     = "nobody@dell.org"
    environment = "sbx"
    program     = "dyl"
    repository  = "terraform-azurerm-storage-account"
    workload    = "apps"
  }
}
