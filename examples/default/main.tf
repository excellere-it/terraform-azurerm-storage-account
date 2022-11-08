module "example" {
  source = "../.."

  location = "centralus"

  # The following tokens are optional: instance, program
  name = {
    workload    = "apps"
    instance    = 0
    environment = "sbx"
    program     = "dyl"
  }

  # Program is optional. To meet compliance requirements, the module uses "Shared" when the tag is omitted.
  required_tags = {
    Contact    = "nobody@dell.org"
    Program    = "DYL"
    Repository = "terraform-azurerm-resource-group"
  }
}