# =============================================================================
# Azure Container App Module — Input Variables
# =============================================================================

variable "name_prefix" {
  type        = string
  description = "Prefix for all resource names"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy into"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the Container App Environment (must be delegated to Microsoft.App/environments)"
  default     = ""
}

variable "container_image" {
  type        = string
  description = "Container image to deploy (e.g. mcr.microsoft.com/azuredocs/containerapps-helloworld:latest)"
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

variable "min_replicas" {
  type        = number
  description = "Minimum number of replicas"
  default     = 0
}

variable "max_replicas" {
  type        = number
  description = "Maximum number of replicas"
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

variable "transport" {
  type        = string
  description = "Ingress transport protocol (auto, http, http2, tcp)"
  default     = "auto"
}

variable "env_vars" {
  type = list(object({
    name  = string
    value = optional(string)
  }))
  description = "Environment variables for the container"
  default     = []
}

variable "revision_mode" {
  type        = string
  description = "Revision mode (Single or Multiple)"
  default     = "Single"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID (created internally if empty)"
  default     = ""
}

variable "extra_tags" {
  type        = map(string)
  description = "Additional tags to apply to resources"
  default     = {}
}
