locals {
  test_namespace = random_pet.instance_id.id

  name = {
    contact     = "nobody@dell.org"
    environment = "sbx"
    program     = "dyl"
    repository  = "terraform-azurerm-key-vault"
    workload    = "apps"
  }
}

resource "random_pet" "instance_id" {}

resource "azurerm_resource_group" "example" {
  location = "centralus"
  name     = "rg-${local.test_namespace}"
  tags     = module.name.tags
}

module "example" {
  source = "../.."

  resource_group = azurerm_resource_group.example

  name = {
    contact     = "nobody@dell.org"
    environment = "sbx"
    program     = "dyl"
    repository  = "terraform-azurerm-storage-account"
    workload    = "apps"
  }
}
