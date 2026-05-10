variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.medium"
}

variable "instance_count" {
  type        = number
  description = "Number of instances"
  default     = 1
}

variable "ami_id" {
  type        = string
  description = "AMI ID (leave empty for latest Amazon Linux 2023)"
  default     = ""
}

variable "key_name" {
  type        = string
  description = "SSH key pair name"
  default     = ""
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs to launch instances in"
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
