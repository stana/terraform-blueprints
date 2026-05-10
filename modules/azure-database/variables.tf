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

variable "delegated_subnet_id" {
  type        = string
  description = "Delegated subnet ID for PostgreSQL"
  default     = null
}

variable "private_dns_zone_id" {
  type        = string
  description = "Private DNS zone ID"
  default     = null
}

variable "sku_name" {
  type        = string
  description = "PostgreSQL Flexible Server SKU"
  default     = "B_Standard_B1ms"
}

variable "storage_mb" {
  type        = number
  description = "Storage in MB"
  default     = 32768
}

variable "db_version" {
  type        = string
  description = "PostgreSQL version"
  default     = "15"
}

variable "db_name" {
  type        = string
  description = "Name of the database to create"
}

variable "admin_username" {
  type        = string
  description = "Administrator username"
  default     = "dbadmin"
}

variable "env_stage" {
  type        = string
  description = "Environment stage (used for backup/HA decisions)"
}

variable "extra_tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}
