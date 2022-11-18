module "name" {
  source  = "app.terraform.io/dellfoundation/namer/terraform"
  version = "0.0.2"

  contact         = var.name.contact
  environment     = var.name.environment
  expiration_days = var.expiration_days
  instance        = var.name.instance
  location        = var.resource_group.location
  optional_tags   = var.optional_tags
  program         = var.name.program
  repository      = var.name.repository
  workload        = var.name.workload
}

resource "azurerm_storage_account" "sa" {
  account_replication_type          = "ZRS"
  account_tier                      = "Standard"
  allow_nested_items_to_be_public   = false
  enable_https_traffic_only         = true
  infrastructure_encryption_enabled = true
  location                          = var.resource_group.location
  min_tls_version                   = "TLS1_2"
  name                              = "sa${module.name.resource_suffix_compact}"
  resource_group_name               = var.resource_group.name
  tags                              = module.name.tags

  blob_properties {
    container_delete_retention_policy { days = 30 }
    delete_retention_policy { days = 30 }
    versioning_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  network_rules {
    bypass                     = ["AzureServices", "Logging", "Metrics"]
    default_action             = "Allow"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
}