variable "expiration_years" {
  default     = 1
  description = "Used to calculate the value of the EndDate tag by adding the specified number of years to the CreateDate tag."
  type        = number

  validation {
    condition     = 0 < var.expiration_years
    error_message = "Expiration years must be greater than zero."
  }
}

variable "location" {
  description = "The Azure Region to deploy the resource into."
  type        = string

  validation {
    condition     = contains(["centralus", "eastus2", "southafricanorth", "southafricawest"], var.location)
    error_message = "Must be one of: centralus, eastus2, southafricanorth, southafricawest."
  }
}

variable "name" {
  description = "The name tokens used to construct the resource name."
  type = object({
    environment = string
    instance    = optional(number)
    program     = optional(string)
    workload    = string
  })
}

variable "optional_tags" {
  default     = {}
  description = "A map of additional tags for the resource."
  type        = map(string)
}

variable "required_tags" {
  description = "A map of tags required to meet the tag compliance policy."
  type = object({
    Contact    = string
    Program    = optional(string, "Shared")
    Repository = string
  })
}
