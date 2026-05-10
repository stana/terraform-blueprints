# =============================================================================
# Data Pipeline Blueprint — Input Variables
#
# Simplified interface for deploying data processing infrastructure.
# Composes: networking + compute (workers) + object storage
# No database by default (pipelines typically read/write to storage).
# =============================================================================

# -----------------------------------------------------------------------------
# Identity & Environment
# -----------------------------------------------------------------------------

variable "name_prefix" {
  type        = string
  description = "Prefix for all resource names"
}

variable "env_stage" {
  type        = string
  description = "Environment stage (sandbox, dev, test, prod)"
}

variable "cloud_provider" {
  type        = string
  description = "Cloud provider (aws or azure)"
  default     = "azure"
}

# -----------------------------------------------------------------------------
# AWS-specific
# -----------------------------------------------------------------------------

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = []
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = []
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = []
}

variable "worker_instance_type" {
  type        = string
  description = "Instance type for pipeline workers"
  default     = "t3.large"
}

variable "worker_count" {
  type        = number
  description = "Number of pipeline worker instances"
  default     = 2
}

variable "ami_id" {
  type    = string
  default = ""
}

variable "key_name" {
  type    = string
  default = ""
}

# -----------------------------------------------------------------------------
# Azure-specific
# -----------------------------------------------------------------------------

variable "azure_location" {
  type    = string
  default = "uksouth"
}

variable "azure_vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "azure_subnet_prefixes" {
  type    = list(string)
  default = []
}

variable "azure_subnet_names" {
  type    = list(string)
  default = []
}

variable "azure_worker_vm_size" {
  type    = string
  default = "Standard_D4s_v3"
}

variable "azure_worker_count" {
  type    = number
  default = 2
}

variable "azure_admin_username" {
  type    = string
  default = "azureadmin"
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
# Pipeline-level knobs
# -----------------------------------------------------------------------------

variable "storage_bucket_name" {
  type        = string
  description = "Name for the data storage bucket/container"
  default     = ""
}

variable "enable_versioning" {
  type        = bool
  description = "Enable object versioning on the storage bucket"
  default     = true
}

variable "data_retention_days" {
  type        = number
  description = "Days to retain processed data before lifecycle transition"
  default     = 90
}

variable "enable_encryption" {
  type        = bool
  description = "Enable server-side encryption on storage"
  default     = true
}

variable "extra_tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}
