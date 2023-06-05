locals {
  subresource = var.private_endpoint.enabled ? var.private_endpoint.subresource : {}

  alert = {
    APAT = {
      aggregation = "Average"
      description = "Alert on Storage Account Threshold - Account availability less than 98% for 5 minutes"
      frequency   = "PT1M"
      metric_name = "Availability"
      operator    = "LessThan"
      severity    = 1
      threshold   = 98
      window_size = "PT5M"
    }
  }
}

resource "azurerm_monitor_metric_alert" "alert" {
  for_each = local.alert

  description         = each.value.description
  frequency           = each.value.frequency
  name                = "alert-sa-${each.key}-${module.name.resource_suffix}"
  resource_group_name = var.resource_group.name
  scopes              = [azurerm_storage_account.sa.id]
  severity            = each.value.severity
  tags                = module.name.tags
  window_size         = each.value.window_size

  action {
    action_group_id = var.action_group_id
  }

  criteria {
    aggregation      = each.value.aggregation
    metric_name      = each.value.metric_name
    metric_namespace = "Microsoft.Storage/storageaccounts"
    operator         = each.value.operator
    threshold        = each.value.threshold
  }
}

resource "azurerm_storage_account" "sa" {
  account_replication_type          = "RAGZRS"
  account_tier                      = "Standard"
  allow_nested_items_to_be_public   = false
  enable_https_traffic_only         = true
  infrastructure_encryption_enabled = true
  location                          = var.resource_group.location
  min_tls_version                   = "TLS1_2"
  name                              = "sa${module.name.resource_suffix_short_compact}"
  public_network_access_enabled     = var.testing
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
    bypass         = ["AzureServices", "Logging", "Metrics"]
    default_action = var.testing ? "Allow" : "Deny"
  }
}

resource "azurerm_storage_container" "container" {
  depends_on = [module.private_endpoint]
  for_each   = toset(var.containers)

  name                  = each.key
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_storage_share" "share" {
  depends_on = [module.private_endpoint]
  for_each   = toset(var.shares)

  enabled_protocol     = "SMB"
  name                 = each.key
  quota                = 50
  storage_account_name = azurerm_storage_account.sa.name
}

module "diagnostics" {
  source  = "app.terraform.io/dellfoundation/diagnostics/azurerm"
  version = "0.0.10"

  log_analytics_workspace_id = var.log_analytics_workspace_id

  monitored_services = {
    blobs = {
      id    = "${azurerm_storage_account.sa.id}/blobServices/default/"
      table = "None"
    }
    files = {
      id    = "${azurerm_storage_account.sa.id}/fileServices/default/"
      table = "None"
    }
  }
}

module "name" {
  source  = "app.terraform.io/dellfoundation/namer/terraform"
  version = "0.0.7"

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

module "private_endpoint" {
  source  = "app.terraform.io/dellfoundation/private-link/azurerm"
  version = "0.0.4"

  resource_group  = var.resource_group
  resource_id     = azurerm_storage_account.sa.id
  resource_prefix = azurerm_storage_account.sa.name
  subnet_id       = var.private_endpoint.subnet_id
  subresource     = local.subresource
  tags            = module.name.tags
}