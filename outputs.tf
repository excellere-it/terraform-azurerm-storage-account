output "containers" {
  description = "The storage account containers."
  value       = azurerm_storage_container.container
}

output "id" {
  description = "Storage Account ID."
  value       = azurerm_storage_account.sa.id
}

output "name" {
  description = "The storage account name."
  value       = azurerm_storage_account.sa.name
}

output "primary_access_key" {
  description = "The storage account primary access key."
  sensitive   = true
  value       = azurerm_storage_account.sa.primary_access_key
}

output "primary_blob_endpoint" {
  description = "The storage account primary blob endpoint."
  value       = azurerm_storage_account.sa.primary_blob_endpoint
}

output "primary_connection_string" {
  description = "The storage account primary connection string."
  sensitive   = true
  value       = azurerm_storage_account.sa.primary_connection_string
}