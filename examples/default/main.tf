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

module "name" {
  source  = "app.terraform.io/dellfoundation/namer/terraform"
  version = "0.0.2"

  contact     = local.name.contact
  environment = local.name.environment
  location    = "centralus"
  program     = local.name.program
  repository  = local.name.repository
  workload    = local.name.workload
}

resource "random_pet" "instance_id" {}

resource "azurerm_resource_group" "example" {
  location = "centralus"
  name     = "rg-${local.test_namespace}"
  tags     = module.name.tags
}

module "example" {
  source = "../.."

  location       = azurerm_resource_group.example.location
  resource_group = azurerm_resource_group.example

  name = {
    contact     = "nobody@dell.org"
    environment = "sbx"
    program     = "dyl"
    repository  = "terraform-azurerm-storage-account"
    workload    = "apps"
  }
}
