module "name" {
  source = "git::https://github.com/excellere-it/terraform-terraform-namer.git"

  contact     = "nobody@infoex.dev"
  environment = "sbx"
  location    = local.location
  program     = "dyl"
  repository  = "terraform-azurerm-storage-account"
  workload    = "nople"
}