# =============================================================================
# Module: Azure Storage Account
# =============================================================================
#
# Purpose:
#   This module creates and manages an Azure Storage Account with enterprise-grade
#   security defaults, monitoring, and backup capabilities for blob containers
#   and file shares.
#
# Features:
#   - Secure storage account with HTTPS-only and TLS 1.2 enforcement
#   - Infrastructure encryption enabled by default
#   - System-assigned managed identity for secure access
#   - Blob versioning and retention policies (30 days)
#   - File share retention policies (30 days)
#   - Optional private endpoint connectivity
#   - Optional metric alerting for availability monitoring
#   - Optional Azure Backup protection for file shares
#   - Diagnostic logging to Log Analytics workspace
#   - Network security with configurable IP restrictions
#   - Support for multiple storage redundancy options (RAGZRS, GRS, LRS, ZRS)
#
# Resources Created:
#   - azurerm_storage_account - Main storage account resource
#   - azurerm_storage_container - Blob containers (optional, configurable)
#   - azurerm_storage_share - File shares (optional, configurable)
#   - azurerm_monitor_metric_alert - Availability alerts (optional)
#   - azurerm_backup_container_storage_account - Backup container (optional)
#   - azurerm_backup_protected_file_share - File share backup (optional)
#
# Dependencies:
#   - terraform-terraform-namer (required for naming and tagging)
#   - terraform-azurerm-diagnostics (required for logging)
#   - terraform-azurerm-private-link (optional for private endpoints)
#
# Security Defaults:
#   - HTTPS-only traffic enforcement
#   - Minimum TLS version 1.2
#   - Infrastructure encryption enabled
#   - Public network access disabled by default (production mode)
#   - Blob versioning and retention policies (30 days)
#   - System-assigned managed identity
#   - Private blob container access only
#   - Network rules with deny-by-default (unless testing mode)
#
# Usage:
#   module "storage" {
#     source = "app.terraform.io/infoex/storage-account/azurerm"
#
#     # Required variables
#     contact                    = "admin@example.com"
#     environment                = "prd"
#     location                   = "centralus"
#     repository                 = "infrastructure-repo"
#     workload                   = "application"
#     resource_group             = azurerm_resource_group.example
#     log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
#
#     # Optional monitoring and backup
#     action_group_id            = azurerm_monitor_action_group.example.id
#     backup_policy_id           = azurerm_backup_policy_file_share.example.id
#     recovery_vault = {
#       name                = azurerm_recovery_services_vault.example.name
#       resource_group_name = azurerm_resource_group.example.name
#     }
#
#     # Storage configuration
#     sku                            = "RAGZRS"
#     public_network_access_enabled  = false
#     containers                     = ["data", "logs"]
#     shares = {
#       "shared-files" = { quota = 100 }
#     }
#   }
#
# =============================================================================

# =============================================================================
# Section: Naming and Tagging
# =============================================================================

module "naming" {
  source  = "app.terraform.io/infoex/namer/terraform"
  version = "0.0.2"

  contact       = var.contact
  environment   = var.environment
  location      = var.is_global ? "global" : var.resource_group.location
  repository    = var.repository
  workload      = var.workload
  optional_tags = var.optional_tags
  resource_type = "storageStorageAccounts"
}

# =============================================================================
# Section: Locals
# =============================================================================

locals {
  subresource = var.private_endpoint.enabled ? var.private_endpoint.subresource : {}
  ip_rules    = var.ip_restriction.enabled ? [for _, v in var.ip_restriction.ip : v.ip_address] : []

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

# =============================================================================
# Section: Main Resources
# =============================================================================

resource "azurerm_storage_account" "sa" {
  account_replication_type          = var.sku
  account_tier                      = "Standard"
  allow_nested_items_to_be_public   = false
  https_traffic_only_enabled        = true
  infrastructure_encryption_enabled = true
  location                          = var.resource_group.location
  min_tls_version                   = "TLS1_2"
  name                              = "sa${module.naming.resource_suffix_short_compact}"
  public_network_access_enabled     = var.public_network_access_enabled
  resource_group_name               = var.resource_group.name
  tags                              = module.naming.tags

  blob_properties {
    container_delete_retention_policy { days = 30 }
    delete_retention_policy { days = 30 }
    versioning_enabled = true
  }

  share_properties {
    retention_policy { days = 30 }
  }

  # Identity configuration
  # SystemAssigned for general access, UserAssigned added when CMK is enabled
  identity {
    type = var.customer_managed_key != null ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = var.customer_managed_key != null ? [
      var.customer_managed_key.user_assigned_identity_id
    ] : null
  }

  # Customer-managed key encryption (optional)
  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key != null ? [var.customer_managed_key] : []
    content {
      key_vault_key_id          = customer_managed_key.value.key_vault_key_id
      user_assigned_identity_id = customer_managed_key.value.user_assigned_identity_id
    }
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

module "diagnostics" {
  source  = "app.terraform.io/infoex/diagnostics/azurerm"
  version = "0.0.3"

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

module "private_endpoint" {
  source  = "app.terraform.io/infoex/private-link/azurerm"
  version = "0.0.3"

  name = {
    contact     = var.contact
    environment = var.environment
    location    = var.location
    repository  = var.repository
    workload    = var.workload
  }

  resource_group = var.resource_group
  resource_id    = azurerm_storage_account.sa.id
  subnet_id      = var.private_endpoint.subnet_id
  subresource    = local.subresource
  optional_tags  = var.optional_tags
}

# =============================================================================
# Section: Monitoring (Optional)
# =============================================================================

resource "azurerm_monitor_metric_alert" "alert" {
  for_each = var.action_group_id != null ? local.alert : {}

  description         = each.value.description
  frequency           = each.value.frequency
  name                = "alert-sa-${each.key}-${module.naming.resource_suffix}"
  resource_group_name = var.resource_group.name
  scopes              = [azurerm_storage_account.sa.id]
  severity            = each.value.severity
  tags                = module.naming.tags
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

# =============================================================================
# Section: Backup Protection (Optional)
# =============================================================================

resource "azurerm_backup_protected_file_share" "share" {
  for_each = var.backup_policy_id != null ? azurerm_storage_share.share : {}

  resource_group_name       = var.recovery_vault.resource_group_name
  recovery_vault_name       = var.recovery_vault.name
  source_storage_account_id = azurerm_backup_container_storage_account.protection_container[0].storage_account_id
  source_file_share_name    = each.value.name
  backup_policy_id          = var.backup_policy_id
}

resource "azurerm_backup_container_storage_account" "protection_container" {
  count = var.backup_policy_id != null ? 1 : 0

  resource_group_name = var.recovery_vault.resource_group_name
  recovery_vault_name = var.recovery_vault.name
  storage_account_id  = azurerm_storage_account.sa.id
}
