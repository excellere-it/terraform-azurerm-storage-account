variable "action_group_id" {
  description = "The ID of the action group to send alerts to."
  type        = string
}

variable "containers" {
  default     = []
  description = "When provided the module will create private blob containers for each item in the list."
  type        = list(string)
}

variable "expiration_days" {
  default     = 365
  description = "Used to calculate the value of the EndDate tag by adding the specified number of days to the CreateDate tag."
  type        = number

  validation {
    condition     = 0 < var.expiration_days
    error_message = "Expiration days must be greater than zero."
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

variable "log_analytics_workspace_id" {
  description = "The workspace to write logs into."
  type        = string
}

variable "optional_tags" {
  default     = {}
  description = "A map of additional tags for the resource."
  type        = map(string)
}

variable "private_endpoint" {
  description = "The private endpoint configuration."
  type = object({
    subnet_id   = string
    subresource = map(list(string))
  })
}

variable "resource_group" {
  description = "The resource group to deploy resources into"

  type = object({
    location = string
    name     = string
  })
}

variable "shares" {
  default     = []
  description = "When provided the module will create file shares for each item in the list."
  type        = list(string)
}