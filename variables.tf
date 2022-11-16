variable "location" {
  description = "The Azure Region to deploy the resource into."
  type        = string

  validation {
    condition     = contains(["centralus", "eastus2", "southafricanorth", "southafricawest"], var.location)
    error_message = "Must be one of: centralus, eastus2, southafricanorth, southafricawest."
  }
}

variable "name" {
  description = "The name tokens used to construct the resource name and tags."
  type = object({
    contact     = string
    environment = string
    instance    = optional(number)
    program     = optional(string)
    repository  = string
    workload    = string
  })
}

variable "optional_tags" {
  default     = {}
  description = "A map of additional tags for the resource."
  type        = map(string)
}

variable "resource_group" {
  description = "The resource group to deploy resources into"

  type = object({
    location = string
    name     = string
  })
}
