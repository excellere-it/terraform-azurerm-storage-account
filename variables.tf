# =============================================================================
# Required Variables - terraform-namer Inputs
# =============================================================================

variable "contact" {
  type        = string
  description = "Contact email for resource ownership and notifications"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, stg, prd, etc.)"
}

variable "location" {
  type        = string
  description = "Azure region where the Storage Account will be deployed"
}

variable "repository" {
  type        = string
  description = "Source repository name for tracking and documentation"
}

variable "workload" {
  type        = string
  description = "Workload or application name for resource identification"
}

# =============================================================================
# Required Variables - Resource Configuration
# =============================================================================

variable "resource_group" {
  description = "The resource group to deploy resources into"
  type = object({
    location = string
    name     = string
  })
}

variable "log_analytics_workspace_id" {
  description = "The workspace to write logs into for diagnostic settings"
  type        = string
}

# =============================================================================
# Optional Variables - Network Configuration
# =============================================================================

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled for the storage account. Set to true for testing, false for production security"
  default     = false
}

variable "ip_restriction" {
  description = "The IP restriction configuration for network rules"
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

variable "private_endpoint" {
  description = "The private endpoint configuration for secure connectivity"
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

# =============================================================================
# Optional Variables - Storage Configuration
# =============================================================================

variable "sku" {
  default     = "RAGZRS"
  description = "The SKU to use for the storage account (RAGZRS, GRS, LRS, ZRS)"
  type        = string
}

variable "containers" {
  default     = []
  description = "List of blob container names to create with private access"
  type        = list(string)
}

variable "shares" {
  default     = {}
  description = "Map of file share names to configuration with optional quota in GB"
  type = map(object({
    quota = optional(number)
  }))
}

variable "is_global" {
  description = "Whether the resource is considered a global resource (affects naming location)"
  type        = bool
  default     = false
}

variable "testing" {
  default     = false
  description = "When true the module will use testing mode with relaxed network rules (Allow instead of Deny)"
  type        = bool
}

# =============================================================================
# Optional Variables - Monitoring and Backup
# =============================================================================

variable "action_group_id" {
  description = "The ID of the action group to send alerts to. Set to null to disable monitoring alerts"
  type        = string
  default     = null
}

variable "backup_policy_id" {
  description = "Backup Policy ID for file share protection. Set to null to disable backup"
  type        = string
  default     = null
}

variable "recovery_vault" {
  description = "Recovery vault configuration for backup protection. Required if backup_policy_id is set"
  type = object({
    resource_group_name = string
    name                = string
  })
  default = null
}

# =============================================================================
# Optional Variables - Tagging
# =============================================================================

variable "expiration_days" {
  default     = 365
  description = "Used to calculate the value of the EndDate tag by adding the specified number of days to the CreateDate tag"
  type        = number

  validation {
    condition     = 0 < var.expiration_days
    error_message = "Expiration days must be greater than zero."
  }
}

variable "optional_tags" {
  default     = {}
  description = "A map of additional tags to apply to the resource"
  type        = map(string)
}