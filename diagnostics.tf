module "diagnostics" {
  source  = "app.terraform.io/dellfoundation/diagnostics/azurerm"
  version = "0.0.5"

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