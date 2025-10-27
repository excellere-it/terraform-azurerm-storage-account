module "name" {
  source  = "app.terraform.io/infoex/namer/terraform"
  version = "~> 0.0"

  contact     = "nobody@infoex.dev"
  environment = "sbx"
  location    = local.location
  program     = "dyl"
  repository  = "terraform-azurerm-storage-account"
  workload    = "nople"
}