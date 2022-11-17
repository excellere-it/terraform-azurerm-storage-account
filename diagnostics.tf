locals {
  monitored_services = {
    blobs = "${azurerm_storage_account.sa.id}/blobServices/default/"
    files = "${azurerm_storage_account.sa.id}/fileServices/default/"
  }
}

data "azurerm_monitor_diagnostic_categories" "categories" {
  for_each = local.monitored_services

  resource_id = each.value
}

resource "azurerm_monitor_diagnostic_setting" "setting" {
  for_each = local.monitored_services

  name                           = "diag-${each.key}"
  target_resource_id             = each.value
  log_analytics_destination_type = "Dedicated"
  log_analytics_workspace_id     = var.log_analytics_workspace_id

  dynamic "log" {
    for_each = data.azurerm_monitor_diagnostic_categories.categories[each.key].logs

    content {
      category = log.value
      enabled  = true

      retention_policy {
        days    = 0
        enabled = false
      }
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.categories[each.key].metrics

    content {
      category = metric.value
      enabled  = true

      retention_policy {
        days    = 0
        enabled = false
      }
    }
  }
}