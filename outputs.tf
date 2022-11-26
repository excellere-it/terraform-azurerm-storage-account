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