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

resource "random_pet" "instance_id" {}


module "example" {
  source = "../.."

  action_group_id            = azurerm_monitor_action_group.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  resource_group             = azurerm_resource_group.example
  testing                    = false

  containers = [
    "sqlreports"
  ]

  name = {
    contact     = "nobody@dell.org"
    environment = "sbx"
    instance    = 0
    program     = "dyl"
    repository  = "terraform-azurerm-storage-account"
    workload    = "nople"
  }

  private_endpoint = {
    enabled = false
  }

  shares = [
    "university-success"
  ]
}
