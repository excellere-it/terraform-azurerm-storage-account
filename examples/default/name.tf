module "name" {
  source  = "app.terraform.io/dellfoundation/namer/terraform"
  version = "0.0.2"

  contact     = "nobody@dell.org"
  environment = "sbx"
  location    = "centralus"
  program     = "dyl"
  repository  = "terraform-azurerm-storage-account"
  workload    = "apps"
}