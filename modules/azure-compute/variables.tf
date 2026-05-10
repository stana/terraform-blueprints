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

variable "vm_size" {
  type        = string
  description = "Azure VM size"
  default     = "Standard_B2s"
}

variable "vm_count" {
  type        = number
  description = "Number of VMs"
  default     = 1
}

variable "admin_username" {
  type        = string
  description = "Admin username for VMs"
  default     = "azureadmin"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the VMs"
}

variable "extra_tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}
