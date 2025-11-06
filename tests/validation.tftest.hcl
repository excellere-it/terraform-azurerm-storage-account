# Input validation tests for the storage account module

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

run "test_invalid_expiration_days_zero" {
  command = plan

  variables {
    expiration_days = 0
  }

  expect_failures = [
    var.expiration_days
  ]
}

run "test_invalid_expiration_days_negative" {
  command = plan

  variables {
    expiration_days = -1
  }

  expect_failures = [
    var.expiration_days
  ]
}

run "test_valid_expiration_days" {
  command = plan

  variables {
    expiration_days = 365
  }

  assert {
    condition     = var.expiration_days == 365
    error_message = "Expiration days should accept positive values"
  }
}

run "test_ip_restriction_enabled_without_ip_list" {
  command = plan

  variables {
    ip_restriction = {
      enabled = true
      ip      = null
    }
  }

  expect_failures = [
    var.ip_restriction
  ]
}

run "test_ip_restriction_disabled_without_ip_list" {
  command = plan

  variables {
    ip_restriction = {
      enabled = false
      ip      = null
    }
  }

  assert {
    condition     = var.ip_restriction.enabled == false
    error_message = "IP restriction should be allowed to be disabled without IP list"
  }
}

run "test_ip_restriction_enabled_with_ip_list" {
  command = plan

  variables {
    ip_restriction = {
      enabled = true
      ip = {
        office = {
          ip_address = "203.0.113.0"
          name       = "office"
        }
      }
    }
  }

  assert {
    condition     = var.ip_restriction.enabled == true
    error_message = "IP restriction should be allowed when IP list is provided"
  }
}

run "test_private_endpoint_enabled_without_subnet" {
  command = plan

  variables {
    private_endpoint = {
      enabled     = true
      subnet_id   = null
      subresource = { blob = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"] }
    }
  }

  expect_failures = [
    var.private_endpoint
  ]
}

run "test_private_endpoint_enabled_without_subresource" {
  command = plan

  variables {
    private_endpoint = {
      enabled     = true
      subnet_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
      subresource = null
    }
  }

  expect_failures = [
    var.private_endpoint
  ]
}

run "test_private_endpoint_disabled_without_config" {
  command = plan

  variables {
    private_endpoint = {
      enabled     = false
      subnet_id   = null
      subresource = null
    }
  }

  assert {
    condition     = var.private_endpoint.enabled == false
    error_message = "Private endpoint should be allowed to be disabled without configuration"
  }
}

run "test_private_endpoint_enabled_with_full_config" {
  command = plan

  variables {
    private_endpoint = {
      enabled   = true
      subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
      subresource = {
        blob = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"],
        file = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net"]
      }
    }
  }

  assert {
    condition     = var.private_endpoint.enabled == true
    error_message = "Private endpoint should be allowed when fully configured"
  }
}

run "test_empty_containers_list" {
  command = plan

  variables {
    containers = []
  }

  assert {
    condition     = length(azurerm_storage_container.container) == 0
    error_message = "Should create no containers when list is empty"
  }
}

run "test_empty_shares_map" {
  command = plan

  variables {
    shares = {}
  }

  assert {
    condition     = length(azurerm_storage_share.share) == 0
    error_message = "Should create no shares when map is empty"
  }
}

run "test_valid_sku_ragzrs" {
  command = plan

  variables {
    sku = "RAGZRS"
  }

  assert {
    condition     = azurerm_storage_account.sa.account_replication_type == "RAGZRS"
    error_message = "Should accept RAGZRS SKU"
  }
}

run "test_valid_sku_grs" {
  command = plan

  variables {
    sku = "GRS"
  }

  assert {
    condition     = azurerm_storage_account.sa.account_replication_type == "GRS"
    error_message = "Should accept GRS SKU"
  }
}

run "test_valid_sku_lrs" {
  command = plan

  variables {
    sku = "LRS"
  }

  assert {
    condition     = azurerm_storage_account.sa.account_replication_type == "LRS"
    error_message = "Should accept LRS SKU"
  }
}

run "test_valid_sku_zrs" {
  command = plan

  variables {
    sku = "ZRS"
  }

  assert {
    condition     = azurerm_storage_account.sa.account_replication_type == "ZRS"
    error_message = "Should accept ZRS SKU"
  }
}

run "test_optional_tags" {
  command = plan

  variables {
    optional_tags = {
      CostCenter = "12345"
      Owner      = "TeamA"
    }
  }

  assert {
    condition     = var.optional_tags != null
    error_message = "Should accept optional tags"
  }
}

run "test_empty_optional_tags" {
  command = plan

  variables {
    optional_tags = {}
  }

  assert {
    condition     = var.optional_tags != null
    error_message = "Should accept empty optional tags map"
  }
}
