locals {
  public_network_access_enabled = var.testing || var.ip_restriction.enabled
  subresource                   = var.private_endpoint.enabled ? var.private_endpoint.subresource : {}
  ip_rules                      = var.ip_restriction.enabled ? [for _, v in var.ip_restriction.ip : v.ip_address] : []

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
  account_replication_type          = var.sku
  account_tier                      = "Standard"
  allow_nested_items_to_be_public   = false
  enable_https_traffic_only         = true
  infrastructure_encryption_enabled = true
  location                          = var.resource_group.location
  min_tls_version                   = "TLS1_2"
  name                              = "sa${module.name.resource_suffix_short_compact}"
  public_network_access_enabled     = true
  resource_group_name               = var.resource_group.name
  tags                              = module.name.tags

  blob_properties {
    container_delete_retention_policy { days = 30 }
    delete_retention_policy { days = 30 }
    versioning_enabled = true
  }

  share_properties {
    retention_policy { days = 30 }
  }

  identity {
    type = "SystemAssigned"
  }

  network_rules {
    bypass         = ["AzureServices", "Logging", "Metrics"]
    default_action = var.testing ? "Allow" : "Deny"
    ip_rules       = local.ip_rules
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
  for_each   = var.shares

  enabled_protocol     = "SMB"
  name                 = each.key
  quota                = coalesce(each.value.quota, 50)
  storage_account_name = azurerm_storage_account.sa.name
}

  source  = "app.terraform.io/infoex/diagnostics/azurerm"
  version = "0.0.1"

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

  source  = "app.terraform.io/infoex/namer/terraform"
  version = "0.0.1"

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

  source  = "app.terraform.io/infoex/private-link/azurerm"
  version = "0.0.1"

  resource_group  = var.resource_group
  resource_id     = azurerm_storage_account.sa.id
  resource_prefix = azurerm_storage_account.sa.name
  subnet_id       = var.private_endpoint.subnet_id
  subresource     = local.subresource
  tags            = module.name.tags
}

resource "azurerm_backup_protected_file_share" "share" {
  for_each                  = azurerm_storage_share.share
  resource_group_name       = var.recovery_vault.resource_group_name
  recovery_vault_name       = var.recovery_vault.name
  source_storage_account_id = azurerm_backup_container_storage_account.protection_container.storage_account_id
  source_file_share_name    = each.value.name
  backup_policy_id          = var.backup_policy_id
}

resource "azurerm_backup_container_storage_account" "protection_container" {
  resource_group_name = var.recovery_vault.resource_group_name
  recovery_vault_name = var.recovery_vault.name
  storage_account_id  = azurerm_storage_account.sa.id
}
