module "private_endpoint" {
  source  = "app.terraform.io/dellfoundation/private-link/azurerm"
  version = "0.0.1"

  resource_group  = var.resource_group
  resource_id     = azurerm_storage_account.sa.id
  resource_prefix = azurerm_storage_account.sa.name
  subnet_id       = var.private_endpoint.subnet_id
  subresource     = var.private_endpoint.subresource
  tags            = module.name.tags
}
