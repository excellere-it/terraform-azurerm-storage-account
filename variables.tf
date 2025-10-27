variable "is_global" {
  description = "Is the resource considered a global resource"
  type        = bool
  default     = false
}

variable "action_group_id" {
  description = "The ID of the action group to send alerts to."
  type        = string
}

variable "backup_policy_id" {
  description = "Backup Policy ID"
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

variable "log_analytics_workspace_id" {
  description = "The workspace to write logs into."
  type        = string
}

variable "ip_restriction" {
  description = "The IP restriction configuration."

  default = {
    enabled = false
  }

  type = object({
    enabled = bool
    ip = optional(map(object({
      ip_address = string
      name       = string
    })))
  })

  validation {
    condition     = var.ip_restriction.enabled == false || var.ip_restriction.ip != null
    error_message = "The ip_restriction.ip variable must be set when ip_restriction.enabled is true."
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

variable "private_endpoint" {
  description = "The private endpoint configuration."

  default = {
    enabled = false
  }

  type = object({
    enabled     = bool
    subnet_id   = optional(string)
    subresource = optional(map(list(string)))
  })

  validation {
    condition     = var.private_endpoint.enabled == false || var.private_endpoint.subnet_id != null
    error_message = "The private_endpoint.subnet_id variable must be set when private_endpoint.enabled is true."
  }

  validation {
    condition     = var.private_endpoint.enabled == false || var.private_endpoint.subresource != null
    error_message = "The private_endpoint.subresource variable must be set when private_endpoint.enabled is true."
  }
}

variable "recovery_vault" {
  description = "recovery vault"
  type = object({
    resource_group_name = string
    name                = string
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
  default     = {}
  description = "When provided the module will create file shares for each item in the list with optional quota."
  type = map(object({
    quota = optional(number)
  }))
}

variable "sku" {
  default     = "RAGZRS"
  description = "The SKU to use for the storage account."
  type        = string
}

variable "testing" {
  default     = false
  description = "When true the module will use the testing options; for example public access will be enabled."
  type        = bool

}