# Basic functionality tests for the storage account module

# =============================================================================
# MOCK PROVIDER CONFIGURATION
# =============================================================================

# Mock provider configuration for plan-only testing
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# =============================================================================
# TEST VARIABLES
# =============================================================================

variables {
  # Required variables
  contact                    = "test@example.com"
  environment                = "sbx"
  location                   = "centralus"
  repository                 = "terraform-azurerm-storage-account"
  workload                   = "test"
  log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/test-law"

  resource_group = {
    name     = "rg-test-storage"
    location = "centralus"
  }

  # Optional - set to null to test without monitoring/backup
  action_group_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Insights/actionGroups/test-ag"
  backup_policy_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.RecoveryServices/vaults/test-vault/backupPolicies/test-policy"

  recovery_vault = {
    name                = "test-vault"
    resource_group_name = "rg-test"
  }

  # Testing mode
  public_network_access_enabled = true
  testing                       = true
}

run "test_storage_account_creation" {
  command = plan

  assert {
    condition     = azurerm_storage_account.sa.account_tier == "Standard"
    error_message = "Storage account tier should be Standard"
  }

  assert {
    condition     = azurerm_storage_account.sa.min_tls_version == "TLS1_2"
    error_message = "Minimum TLS version should be TLS1_2"
  }

  assert {
    condition     = azurerm_storage_account.sa.enable_https_traffic_only == true
    error_message = "HTTPS traffic only should be enabled"
  }

  assert {
    condition     = azurerm_storage_account.sa.infrastructure_encryption_enabled == true
    error_message = "Infrastructure encryption should be enabled"
  }
}

run "test_storage_account_default_sku" {
  command = plan

  assert {
    condition     = azurerm_storage_account.sa.account_replication_type == "RAGZRS"
    error_message = "Default SKU should be RAGZRS"
  }
}

run "test_storage_account_custom_sku" {
  command = plan

  variables {
    sku = "LRS"
  }

  assert {
    condition     = azurerm_storage_account.sa.account_replication_type == "LRS"
    error_message = "Storage account SKU should match the provided value"
  }
}

run "test_network_rules_testing_mode" {
  command = plan

  variables {
    testing = true
  }

  assert {
    condition     = azurerm_storage_account.sa.network_rules[0].default_action == "Allow"
    error_message = "Default network action should be Allow when in testing mode"
  }
}

run "test_network_rules_production_mode" {
  command = plan

  variables {
    testing = false
  }

  assert {
    condition     = azurerm_storage_account.sa.network_rules[0].default_action == "Deny"
    error_message = "Default network action should be Deny when not in testing mode"
  }
}

run "test_blob_properties_configured" {
  command = plan

  assert {
    condition     = azurerm_storage_account.sa.blob_properties[0].versioning_enabled == true
    error_message = "Blob versioning should be enabled"
  }

  assert {
    condition     = azurerm_storage_account.sa.blob_properties[0].delete_retention_policy[0].days == 30
    error_message = "Blob delete retention should be 30 days"
  }

  assert {
    condition     = azurerm_storage_account.sa.blob_properties[0].container_delete_retention_policy[0].days == 30
    error_message = "Container delete retention should be 30 days"
  }
}

run "test_share_properties_configured" {
  command = plan

  assert {
    condition     = azurerm_storage_account.sa.share_properties[0].retention_policy[0].days == 30
    error_message = "Share retention should be 30 days"
  }
}

run "test_identity_configured" {
  command = plan

  assert {
    condition     = azurerm_storage_account.sa.identity[0].type == "SystemAssigned"
    error_message = "Storage account should have system-assigned managed identity"
  }
}

run "test_containers_creation" {
  command = plan

  variables {
    containers = ["container1", "container2"]
  }

  assert {
    condition     = length(azurerm_storage_container.container) == 2
    error_message = "Should create 2 containers"
  }
}

run "test_shares_creation" {
  command = plan

  variables {
    shares = {
      share1 = {}
      share2 = { quota = 100 }
    }
  }

  assert {
    condition     = length(azurerm_storage_share.share) == 2
    error_message = "Should create 2 file shares"
  }
}

run "test_share_default_quota" {
  command = plan

  variables {
    shares = {
      share1 = {}
    }
  }

  assert {
    condition     = azurerm_storage_share.share["share1"].quota == 50
    error_message = "Default share quota should be 50 GB"
  }
}

run "test_share_custom_quota" {
  command = plan

  variables {
    shares = {
      share1 = { quota = 200 }
    }
  }

  assert {
    condition     = azurerm_storage_share.share["share1"].quota == 200
    error_message = "Share quota should match the provided value"
  }
}

run "test_monitor_alert_created" {
  command = plan

  assert {
    condition     = length(azurerm_monitor_metric_alert.alert) == 1
    error_message = "Should create 1 monitor metric alert"
  }

  assert {
    condition     = azurerm_monitor_metric_alert.alert["APAT"].severity == 1
    error_message = "Alert severity should be 1"
  }

  assert {
    condition     = azurerm_monitor_metric_alert.alert["APAT"].criteria[0].threshold == 98
    error_message = "Alert threshold should be 98"
  }
}

run "test_outputs_defined" {
  command = plan

  assert {
    condition     = azurerm_storage_account.sa.name != null
    error_message = "Storage account name should be defined"
  }
}

run "test_monitoring_optional" {
  command = plan

  variables {
    action_group_id = null
  }

  assert {
    condition     = length(azurerm_monitor_metric_alert.alert) == 0
    error_message = "No alerts should be created when action_group_id is null"
  }
}

run "test_backup_optional" {
  command = plan

  variables {
    backup_policy_id = null
    recovery_vault   = null
  }

  assert {
    condition     = length(azurerm_backup_container_storage_account.protection_container) == 0
    error_message = "No backup container should be created when backup_policy_id is null"
  }
}

run "test_public_network_access_disabled" {
  command = plan

  variables {
    public_network_access_enabled = false
    testing                       = false
  }

  assert {
    condition     = azurerm_storage_account.sa.public_network_access_enabled == false
    error_message = "Public network access should be disabled when set to false"
  }

  assert {
    condition     = azurerm_storage_account.sa.network_rules[0].default_action == "Deny"
    error_message = "Default network action should be Deny when not in testing mode"
  }
}
