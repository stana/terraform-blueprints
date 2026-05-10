# =============================================================================
# Web App Blueprint — Input Variables
#
# This is the SIMPLIFIED interface that users interact with.
# Instead of configuring networking + compute + database + CDN + WAF
# individually, consumers just set high-level knobs and the blueprint
# handles the wiring and environment-aware defaults.
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
  description = "Cloud provider (aws or azure)"
  default     = "azure"
}

# -----------------------------------------------------------------------------
# AWS-specific
# -----------------------------------------------------------------------------

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "AWS availability zones"
  default     = []
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs"
  default     = []
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs"
  default     = []
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.medium"
}

variable "instance_count" {
  type        = number
  description = "Number of app instances"
  default     = 1
}

variable "ami_id" {
  type        = string
  description = "AMI ID (empty = latest Amazon Linux 2023)"
  default     = ""
}

variable "key_name" {
  type        = string
  description = "SSH key pair name"
  default     = ""
}

# AWS Database overrides
variable "db_engine" {
  type    = string
  default = "postgres"
}

variable "db_engine_version" {
  type    = string
  default = "15"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

# -----------------------------------------------------------------------------
# Azure-specific
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

variable "azure_db_sku_name" {
  type    = string
  default = "B_Standard_B1ms"
}

variable "azure_db_storage_mb" {
  type    = number
  default = 32768
}

variable "azure_db_version" {
  type    = string
  default = "15"
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
# Application-level knobs (the simplified interface)
# -----------------------------------------------------------------------------

variable "enable_database" {
  type        = bool
  description = "Provision a managed database for the web app"
  default     = true
}

variable "db_name" {
  type        = string
  description = "Application database name"
  default     = "app"
}

variable "db_username" {
  type        = string
  description = "Database admin username"
  default     = "dbadmin"
}

variable "enable_cdn" {
  type        = bool
  description = "Enable CDN for static asset delivery"
  default     = false
}

variable "enable_waf" {
  type        = bool
  description = "Enable Web Application Firewall"
  default     = false
}

variable "enable_ssl" {
  type        = bool
  description = "Enable SSL/TLS termination"
  default     = true
}

variable "extra_tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}
