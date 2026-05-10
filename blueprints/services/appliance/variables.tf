# =============================================================================
# Virtual Machine Blueprint — Input Variables
#
# Simplified interface for deploying Azure VMs with optional
# networking and Key Vault.
# =============================================================================

# -----------------------------------------------------------------------------
# Identity & Environment
# -----------------------------------------------------------------------------

variable "name_prefix" {
  type        = string
  description = "Prefix for all resource names (typically env_name-env_stage)"
}

variable "env_stage" {
  type        = string
  description = "Environment stage (sandbox, dev, test, prod)"
}

variable "cloud_provider" {
  type        = string
  description = "Cloud provider (must be azure for this blueprint)"
  default     = "azure"
}

variable "env_name" {
  type    = string
  default = ""
}

variable "project_name" {
  type    = string
  default = "tffactory"
}

# -----------------------------------------------------------------------------
# Azure Networking (optional — provide external_subnet_id to skip)
# -----------------------------------------------------------------------------

variable "enable_networking" {
  type        = bool
  description = "Create a VNet for the VMs (set false and provide external_subnet_id to use existing)"
  default     = true
}

variable "azure_location" {
  type        = string
  description = "Azure region"
  default     = "uksouth"
}

variable "azure_vnet_address_space" {
  type        = list(string)
  description = "Azure VNet address space"
  default     = ["10.0.0.0/16"]
}

variable "azure_subnet_prefixes" {
  type        = list(string)
  description = "Azure subnet prefixes"
  default     = []
}

variable "azure_subnet_names" {
  type        = list(string)
  description = "Azure subnet names"
  default     = []
}

variable "external_subnet_id" {
  type        = string
  description = "Existing subnet ID to place VMs in (used when enable_networking = false)"
  default     = ""
}

variable "external_resource_group_name" {
  type        = string
  description = "Existing resource group name (used when enable_networking = false)"
  default     = ""
}

# -----------------------------------------------------------------------------
# Azure Virtual Machine
# -----------------------------------------------------------------------------

variable "azure_vm_size" {
  type        = string
  description = "Azure VM size"
  default     = "Standard_B2s"
}

variable "azure_vm_count" {
  type        = number
  description = "Number of Azure VMs"
  default     = 1
}

variable "azure_admin_username" {
  type    = string
  default = "azureadmin"
}

# -----------------------------------------------------------------------------
# Key Vault (optional)
# -----------------------------------------------------------------------------

variable "enable_keyvault" {
  type        = bool
  description = "Provision an Azure Key Vault"
  default     = false
}

variable "keyvault_sku" {
  type        = string
  description = "Key Vault SKU (standard or premium)"
  default     = "standard"
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "extra_tags" {
  type        = map(string)
  description = "Additional tags to apply to all resources"
  default     = {}
}
