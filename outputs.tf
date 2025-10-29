# =============================================================================
# Resource Outputs
# =============================================================================

output "id" {
  description = "The Storage Account resource ID"
  value       = azurerm_storage_account.sa.id
}

output "name" {
  description = "The Storage Account name"
  value       = azurerm_storage_account.sa.name
}

output "containers" {
  description = "The storage account blob containers"
  value       = azurerm_storage_container.container
}

output "shares" {
  description = "The storage account file shares"
  value       = azurerm_storage_share.share
}

# =============================================================================
# Convenience Outputs
# =============================================================================

output "primary_blob_endpoint" {
  description = "The primary blob endpoint URL"
  value       = azurerm_storage_account.sa.primary_blob_endpoint
}

output "primary_access_key" {
  description = "The primary access key for the storage account"
  sensitive   = true
  value       = azurerm_storage_account.sa.primary_access_key
}

output "primary_connection_string" {
  description = "The primary connection string for the storage account"
  sensitive   = true
  value       = azurerm_storage_account.sa.primary_connection_string
}