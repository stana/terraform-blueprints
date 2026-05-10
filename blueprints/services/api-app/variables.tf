# =============================================================================
# Container App Blueprint — Input Variables
#
# Simplified interface for deploying Azure Container Apps.
# Consumers set high-level knobs and the blueprint handles wiring and
# environment-aware defaults.
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

# -----------------------------------------------------------------------------
# Container App Configuration
# -----------------------------------------------------------------------------

variable "container_image" {
  type        = string
  description = "Container image to deploy"
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "container_name" {
  type        = string
  description = "Name of the container"
  default     = "app"
}

variable "container_cpu" {
  type        = number
  description = "CPU cores allocated to the container"
  default     = 0.25
}

variable "container_memory" {
  type        = string
  description = "Memory allocated to the container (e.g. 0.5Gi)"
  default     = "0.5Gi"
}

variable "container_min_replicas" {
  type        = number
  description = "Minimum number of replicas (overridden by env defaults)"
  default     = 0
}

variable "container_max_replicas" {
  type        = number
  description = "Maximum number of replicas (overridden by env defaults)"
  default     = 3
}

variable "target_port" {
  type        = number
  description = "Port the container listens on"
  default     = 80
}

variable "external_ingress" {
  type        = bool
  description = "Whether ingress is externally accessible"
  default     = true
}

variable "revision_mode" {
  type        = string
  description = "Revision mode (Single or Multiple)"
  default     = "Single"
}

variable "container_env_vars" {
  type = list(object({
    name  = string
    value = optional(string)
  }))
  description = "Environment variables for the container"
  default     = []
}

# -----------------------------------------------------------------------------
# Storage (optional)
# -----------------------------------------------------------------------------

variable "enable_storage" {
  type        = bool
  description = "Provision a storage account for the Container App"
  default     = false
}

variable "storage_account_name" {
  type        = string
  description = "Storage account name (auto-generated if empty)"
  default     = ""
}

variable "storage_container_name" {
  type        = string
  description = "Name of the blob container to create"
  default     = "data"
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "extra_tags" {
  type        = map(string)
  description = "Additional tags to apply to all resources"
  default     = {}
}
