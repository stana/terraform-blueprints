# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------

variable "project_name" {
  type        = string
  description = "Project name used for resource naming and tagging"
  default     = "tffactory"
}

variable "env_name" {
  type        = string
  description = "Environment name identifier (e.g. acme, lumon, testhub)"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.env_name))
    error_message = "env_name must be alphanumeric with optional hyphens."
  }
}

variable "env_stage" {
  type        = string
  description = "Environment stage (sandbox, dev, test, prod)"

  validation {
    condition     = contains(["sandbox", "dev", "test", "prod"], var.env_stage)
    error_message = "env_stage must be one of: sandbox, dev, test, prod."
  }
}

variable "cloud_provider" {
  type        = string
  description = "Cloud provider to deploy to (aws or azure)"
  default     = "azure"

  validation {
    condition     = contains(["aws", "azure"], var.cloud_provider)
    error_message = "cloud_provider must be one of: aws, azure."
  }
}

# -----------------------------------------------------------------------------
# AWS
# -----------------------------------------------------------------------------

variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "eu-west-1"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID for this environment"
  default     = ""
}

# -----------------------------------------------------------------------------
# Azure
# -----------------------------------------------------------------------------

variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription ID"
  default     = ""
}

variable "azure_location" {
  type        = string
  description = "Azure region (e.g. uksouth, westeurope, eastus)"
  default     = "uksouth"
}

variable "azure_resource_group_name" {
  type        = string
  description = "Name for the Azure resource group"
  default     = ""
}

variable "azure_vnet_address_space" {
  type        = list(string)
  description = "Address space for the Azure VNet"
  default     = ["10.0.0.0/16"]
}

variable "azure_subnet_prefixes" {
  type        = list(string)
  description = "Subnet address prefixes"
  default     = []
}

variable "azure_subnet_names" {
  type        = list(string)
  description = "Names for each subnet"
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
  type        = string
  description = "Admin username for Azure VMs"
  default     = "azureadmin"
}

variable "azure_db_sku_name" {
  type        = string
  description = "Azure PostgreSQL Flexible Server SKU"
  default     = "B_Standard_B1ms"
}

variable "azure_db_storage_mb" {
  type        = number
  description = "Azure PostgreSQL storage in MB"
  default     = 32768
}

variable "azure_db_version" {
  type        = string
  description = "Azure PostgreSQL version"
  default     = "15"
}

# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to use"
  default     = []
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
  default     = []
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
  default     = []
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Whether to create NAT gateway(s) for private subnets"
  default     = false
}

variable "single_nat_gateway" {
  type        = bool
  description = "Use a single NAT gateway (cost saving for non-prod)"
  default     = true
}

# -----------------------------------------------------------------------------
# Compute
# -----------------------------------------------------------------------------

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.medium"
}

variable "instance_count" {
  type        = number
  description = "Number of EC2 instances to launch"
  default     = 1
}

variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instances (leave empty for latest Amazon Linux 2)"
  default     = ""
}

variable "key_name" {
  type        = string
  description = "SSH key pair name"
  default     = ""
}

# -----------------------------------------------------------------------------
# Database
# -----------------------------------------------------------------------------

variable "enable_database" {
  type        = bool
  description = "Whether to provision the database module"
  default     = false
}

variable "db_engine" {
  type        = string
  description = "Database engine (postgres, mysql)"
  default     = "postgres"
}

variable "db_engine_version" {
  type        = string
  description = "Database engine version"
  default     = "15"
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.medium"
}

variable "db_allocated_storage" {
  type        = number
  description = "Allocated storage in GB"
  default     = 20
}

variable "db_name" {
  type        = string
  description = "Name of the database to create"
  default     = "app"
}

variable "db_username" {
  type        = string
  description = "Master username for the database"
  default     = "dbadmin"
}

variable "db_multi_az" {
  type        = bool
  description = "Enable Multi-AZ deployment"
  default     = false
}

variable "db_deletion_protection" {
  type        = bool
  description = "Enable deletion protection"
  default     = false
}

variable "db_backup_retention_period" {
  type        = number
  description = "Backup retention period in days"
  default     = 1
}

# -----------------------------------------------------------------------------
# Feature Flags
# -----------------------------------------------------------------------------

variable "enable_monitoring" {
  type        = bool
  description = "Enable CloudWatch monitoring and alarms"
  default     = false
}

variable "enable_waf" {
  type        = bool
  description = "Enable WAF (Web Application Firewall)"
  default     = false
}

variable "enable_cdn" {
  type        = bool
  description = "Enable CloudFront CDN"
  default     = false
}

# -----------------------------------------------------------------------------
# Blueprints
# -----------------------------------------------------------------------------

variable "blueprints" {
  type        = list(string)
  description = "List of blueprints to deploy (e.g. [\"web-app\"], [\"web-app\", \"data-pipeline\"])"
  default     = ["web-app"]

  validation {
    condition     = alltrue([for s in var.blueprints : contains(["web-app", "data-pipeline", "api-app", "appliance", "hub-network"], s)])
    error_message = "Each blueprint must be one of: web-app, data-pipeline, api-app, appliance, hub-network."
  }
}

# -----------------------------------------------------------------------------
# Data Pipeline Blueprint Variables
# (only used when "data-pipeline" is in var.blueprints)
# -----------------------------------------------------------------------------

variable "pipeline_vpc_cidr" {
  type        = string
  description = "VPC CIDR for the pipeline network (separate from web-app)"
  default     = "10.100.0.0/16"
}

variable "pipeline_public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs for the pipeline"
  default     = []
}

variable "pipeline_private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs for the pipeline"
  default     = []
}

variable "pipeline_worker_instance_type" {
  type        = string
  description = "EC2 instance type for pipeline workers"
  default     = "t3.large"
}

variable "pipeline_worker_count" {
  type        = number
  description = "Number of pipeline worker instances"
  default     = 2
}

variable "pipeline_storage_bucket_name" {
  type        = string
  description = "Name for the pipeline data storage bucket"
  default     = ""
}

variable "pipeline_enable_versioning" {
  type        = bool
  description = "Enable object versioning on the pipeline storage"
  default     = true
}

variable "pipeline_data_retention_days" {
  type        = number
  description = "Days before processed data transitions to archive storage"
  default     = 90
}

variable "pipeline_enable_encryption" {
  type        = bool
  description = "Enable server-side encryption on pipeline storage"
  default     = true
}

variable "pipeline_azure_vnet_address_space" {
  type        = list(string)
  description = "Azure VNet address space for the pipeline"
  default     = ["10.100.0.0/16"]
}

variable "pipeline_azure_subnet_prefixes" {
  type        = list(string)
  description = "Azure subnet prefixes for the pipeline"
  default     = []
}

variable "pipeline_azure_subnet_names" {
  type        = list(string)
  description = "Azure subnet names for the pipeline"
  default     = []
}

variable "pipeline_azure_worker_vm_size" {
  type        = string
  description = "Azure VM size for pipeline workers"
  default     = "Standard_D4s_v3"
}

# -----------------------------------------------------------------------------
# Container App Blueprint Variables
# (only used when "api-app" is in var.blueprints — Azure only)
# -----------------------------------------------------------------------------

variable "container_app_vnet_address_space" {
  type        = list(string)
  description = "Azure VNet address space for the Container App blueprint"
  default     = ["10.200.0.0/16"]
}

variable "container_app_subnet_prefixes" {
  type        = list(string)
  description = "Azure subnet prefixes for the Container App blueprint"
  default     = []
}

variable "container_app_subnet_names" {
  type        = list(string)
  description = "Azure subnet names for the Container App blueprint"
  default     = []
}

variable "container_app_image" {
  type        = string
  description = "Container image to deploy"
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "container_app_container_name" {
  type        = string
  description = "Name of the container"
  default     = "app"
}

variable "container_app_cpu" {
  type        = number
  description = "CPU cores allocated to the container"
  default     = 0.25
}

variable "container_app_memory" {
  type        = string
  description = "Memory allocated to the container"
  default     = "0.5Gi"
}

variable "container_app_min_replicas" {
  type        = number
  description = "Minimum number of replicas"
  default     = 0
}

variable "container_app_max_replicas" {
  type        = number
  description = "Maximum number of replicas"
  default     = 3
}

variable "container_app_target_port" {
  type        = number
  description = "Port the container listens on"
  default     = 80
}

variable "container_app_external_ingress" {
  type        = bool
  description = "Whether ingress is externally accessible"
  default     = true
}

variable "container_app_revision_mode" {
  type        = string
  description = "Revision mode (Single or Multiple)"
  default     = "Single"
}

variable "container_app_env_vars" {
  type = list(object({
    name  = string
    value = optional(string)
  }))
  description = "Environment variables for the container"
  default     = []
}

variable "container_app_enable_storage" {
  type        = bool
  description = "Provision a storage account for the Container App"
  default     = false
}

variable "container_app_storage_account_name" {
  type        = string
  description = "Storage account name (auto-generated if empty)"
  default     = ""
}

variable "container_app_storage_container_name" {
  type        = string
  description = "Name of the blob container to create"
  default     = "data"
}

# -----------------------------------------------------------------------------
# Virtual Machine Blueprint Variables
# (only used when "appliance" is in var.blueprints — Azure only)
# -----------------------------------------------------------------------------

variable "vm_enable_networking" {
  type        = bool
  description = "Create a VNet for the VMs (false = use vm_external_subnet_id)"
  default     = true
}

variable "vm_vnet_address_space" {
  type        = list(string)
  description = "Azure VNet address space for the VM blueprint"
  default     = ["10.210.0.0/16"]
}

variable "vm_subnet_prefixes" {
  type        = list(string)
  description = "Azure subnet prefixes for the VM blueprint"
  default     = []
}

variable "vm_subnet_names" {
  type        = list(string)
  description = "Azure subnet names for the VM blueprint"
  default     = []
}

variable "vm_external_subnet_id" {
  type        = string
  description = "Existing subnet ID for VMs (used when vm_enable_networking = false)"
  default     = ""
}

variable "vm_external_resource_group_name" {
  type        = string
  description = "Existing resource group name (used when vm_enable_networking = false)"
  default     = ""
}

variable "vm_azure_vm_size" {
  type        = string
  description = "Azure VM size for the VM blueprint"
  default     = "Standard_B2s"
}

variable "vm_azure_vm_count" {
  type        = number
  description = "Number of Azure VMs in the VM blueprint"
  default     = 1
}

variable "vm_enable_keyvault" {
  type        = bool
  description = "Provision an Azure Key Vault alongside VMs"
  default     = false
}

variable "vm_keyvault_sku" {
  type        = string
  description = "Key Vault SKU (standard or premium)"
  default     = "standard"
}

# -----------------------------------------------------------------------------
# Network Hub Blueprint Variables
# (only used when "hub-network" is in var.blueprints — Azure only)
# -----------------------------------------------------------------------------

variable "hub_vnet_address_space" {
  type        = list(string)
  description = "Hub VNet address space"
  default     = ["10.0.0.0/16"]
}

variable "hub_subnet_prefixes" {
  type        = list(string)
  description = "Hub subnet prefixes (excluding Firewall and Bastion subnets)"
  default     = []
}

variable "hub_subnet_names" {
  type        = list(string)
  description = "Hub subnet names (excluding Firewall and Bastion subnets)"
  default     = []
}

variable "hub_enable_firewall" {
  type        = bool
  description = "Provision an Azure Firewall in the hub"
  default     = true
}

variable "hub_firewall_subnet_prefix" {
  type        = string
  description = "Address prefix for AzureFirewallSubnet (must be /26 or larger)"
  default     = "10.0.1.0/26"
}

variable "hub_bastion_subnet_prefix" {
  type        = string
  description = "Address prefix for AzureBastionSubnet (must be /26 or larger)"
  default     = "10.0.2.0/26"
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "extra_tags" {
  type        = map(string)
  description = "Additional tags to apply to all resources (merged with default tags)"
  default     = {}
}
