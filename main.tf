locals {
  tags = merge(module.name.tags, var.optional_tags)
}

module "name" {
  source  = "app.terraform.io/dellfoundation/namer/terraform"
  version = "0.0.2"

  contact     = var.name.contact
  environment = var.name.environment
  instance    = var.name.instance
  location    = var.resource_group.location
  program     = var.name.program
  repository  = var.name.repository
  workload    = var.name.workload
}

resource "azurerm_storage_account" "sa" {
  account_replication_type  = "GRS"
  account_tier              = "Standard"
  enable_https_traffic_only = true
  location                  = var.resource_group.location
  min_tls_version           = "TLS1_2"
  name                      = "satst${module.name.resource_suffix_compact}"
  resource_group_name       = var.resource_group.name
  tags                      = local.tags

  identity {
    type = "SystemAssigned"
  }

  network_rules {
    bypass                     = []
    default_action             = "Allow"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
}