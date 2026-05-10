variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "engine" {
  type        = string
  description = "Database engine (postgres, mysql)"
  default     = "postgres"
}

variable "engine_version" {
  type        = string
  description = "Database engine version"
  default     = "15"
}

variable "instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.medium"
}

variable "allocated_storage" {
  type        = number
  description = "Allocated storage in GB"
  default     = 20
}

variable "db_name" {
  type        = string
  description = "Name of the database to create"
}

variable "username" {
  type        = string
  description = "Master username"
}

variable "multi_az" {
  type        = bool
  description = "Enable Multi-AZ deployment"
  default     = false
}

variable "deletion_protection" {
  type        = bool
  description = "Enable deletion protection"
  default     = false
}

variable "backup_retention_period" {
  type        = number
  description = "Backup retention period in days"
  default     = 1
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for the DB subnet group"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for security group"
}

variable "extra_tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}
