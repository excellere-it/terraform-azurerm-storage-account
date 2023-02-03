module "name" {
  source  = "app.terraform.io/dellfoundation/namer/terraform"
  version = "0.0.5"

  contact     = "nobody@dell.org"
  environment = "sbx"
  location    = local.location
  program     = "dyl"
  repository  = "terraform-azurerm-storage-account"
  workload    = "apps"
}