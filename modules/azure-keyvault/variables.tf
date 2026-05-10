# =============================================================================
# Azure Key Vault Module — Input Variables
# =============================================================================

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "sku_name" {
  type        = string
  description = "Key Vault SKU (standard or premium)"
  default     = "standard"
}

variable "soft_delete_retention_days" {
  type        = number
  description = "Number of days to retain soft-deleted vaults"
  default     = 7
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Enable purge protection"
  default     = false
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "Use Azure RBAC for data plane authorization instead of access policies"
  default     = true
}

variable "network_default_action" {
  type        = string
  description = "Default network ACL action (Allow or Deny)"
  default     = "Allow"
}

variable "extra_tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}
