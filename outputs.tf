output "storage_account_id" {
  description = "Storage Account ID."
  value       = azurerm_storage_account.sa.id
}

output "storage_account_name" {
  description = "Storage Account Name."
  value       = azurerm_storage_account.sa.name
}