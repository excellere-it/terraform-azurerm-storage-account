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