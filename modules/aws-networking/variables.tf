variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Whether to create NAT gateway(s)"
  default     = false
}

variable "single_nat_gateway" {
  type        = bool
  description = "Use a single NAT gateway instead of one per AZ"
  default     = true
}

variable "extra_tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}
