# =============================================================================
# Network Hub Blueprint — Input Variables
#
# Simplified interface for deploying a hub network with optional
# Azure Firewall and Bastion.
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
# Azure Networking
# -----------------------------------------------------------------------------

variable "azure_location" {
  type        = string
  description = "Azure region"
  default     = "uksouth"
}

variable "azure_vnet_address_space" {
  type        = list(string)
  description = "Hub VNet address space"
  default     = ["10.0.0.0/16"]
}

variable "azure_subnet_prefixes" {
  type        = list(string)
  description = "Hub subnet prefixes (excluding Firewall and Bastion subnets)"
  default     = []
}

variable "azure_subnet_names" {
  type        = list(string)
  description = "Hub subnet names (excluding Firewall and Bastion subnets)"
  default     = []
}

# -----------------------------------------------------------------------------
# Azure Firewall
# -----------------------------------------------------------------------------

variable "enable_firewall" {
  type        = bool
  description = "Provision an Azure Firewall in the hub"
  default     = true
}

variable "firewall_subnet_prefix" {
  type        = string
  description = "Address prefix for AzureFirewallSubnet (must be /26 or larger)"
  default     = "10.0.1.0/26"
}

# -----------------------------------------------------------------------------
# Azure Bastion
# -----------------------------------------------------------------------------

variable "bastion_subnet_prefix" {
  type        = string
  description = "Address prefix for AzureBastionSubnet (must be /26 or larger)"
  default     = "10.0.2.0/26"
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "extra_tags" {
  type        = map(string)
  description = "Additional tags to apply to all resources"
  default     = {}
}
