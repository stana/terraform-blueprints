variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group" {
  type        = string
  description = "Resource group name"
}

variable "address_space" {
  type        = list(string)
  description = "VNet address space"
}

variable "subnet_prefixes" {
  type        = list(string)
  description = "Subnet address prefixes"
}

variable "subnet_names" {
  type        = list(string)
  description = "Names for each subnet"
}

variable "env_name" {
  type        = string
  description = "Environment name identifier"
}

variable "env_stage" {
  type        = string
  description = "Environment stage"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "extra_tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}
