locals {
  cloudflare_ips = data.cloudflare_ip_ranges.cloudflare.ipv4_cidr_blocks
  location       = "centralus"
  test_namespace = random_pet.instance_id.id

  ip_restriction = { for v in local.cloudflare_ips : "Cloudflare${index(local.cloudflare_ips, v)}" => {
    ip_address = v
    name       = "Cloudflare${index(local.cloudflare_ips, v)}"
  } }
}

data "cloudflare_ip_ranges" "cloudflare" {}

resource "azurerm_log_analytics_workspace" "example" {
  location            = azurerm_resource_group.example.location
  name                = "la-${local.test_namespace}"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

resource "azurerm_monitor_action_group" "example" {
  name                = "CriticalAlertsAction"
  resource_group_name = azurerm_resource_group.example.name
  short_name          = "p0action"
}

resource "azurerm_resource_group" "example" {
  location = local.location
  name     = "rg-${local.test_namespace}"
}

resource "random_pet" "instance_id" {}

resource "azurerm_recovery_services_vault" "example" {
  name                = "tfex-recovery-vault"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"
}

resource "azurerm_backup_policy_file_share" "example" {
  name                = "tfex-recovery-vault-policy"
  resource_group_name = azurerm_resource_group.example.name
  recovery_vault_name = azurerm_recovery_services_vault.example.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 10
  }

  retention_weekly {
    count    = 7
    weekdays = ["Sunday", "Wednesday", "Friday", "Saturday"]
  }

  retention_monthly {
    count    = 7
    weekdays = ["Sunday", "Wednesday"]
    weeks    = ["First", "Last"]
  }

  retention_yearly {
    count    = 7
    weekdays = ["Sunday"]
    weeks    = ["Last"]
    months   = ["January"]
  }
}

module "example" {
  source = "../.."

  # Required variables
  contact                    = "nobody@infoex.dev"
  environment                = "sbx"
  location                   = local.location
  repository                 = "terraform-azurerm-storage-account"
  workload                   = "nople"
  resource_group             = azurerm_resource_group.example
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  # Optional monitoring and backup
  action_group_id  = azurerm_monitor_action_group.example.id
  backup_policy_id = azurerm_backup_policy_file_share.example.id
  recovery_vault = {
    name                = azurerm_recovery_services_vault.example.name
    resource_group_name = azurerm_resource_group.example.name
  }

  # Storage configuration
  public_network_access_enabled = true
  testing                       = true

  containers = [
    "sqlreports"
  ]

  shares = {
    "university-success" = {}
  }

  ip_restriction = {
    enabled = true
    ip      = local.ip_restriction
  }

  private_endpoint = {
    enabled = false
  }
}
