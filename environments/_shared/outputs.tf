# =============================================================================
# Outputs — routed through blueprints
#
# Blueprints provide a cloud-agnostic output interface.
# These outputs expose the blueprint results to the caller.
# =============================================================================

# -----------------------------------------------------------------------------
# Web App Blueprint
# -----------------------------------------------------------------------------

output "web_app_network_id" {
  description = "Web app network ID (VPC or VNet)"
  value       = local.deploy_web_app ? module.web_app[0].network_id : null
}

output "web_app_subnet_ids" {
  description = "Web app subnet IDs"
  value       = local.deploy_web_app ? module.web_app[0].subnet_ids : null
}

output "web_app_instance_ids" {
  description = "Web app compute instance IDs"
  value       = local.deploy_web_app ? module.web_app[0].compute_instance_ids : null
}

output "web_app_private_ips" {
  description = "Web app compute private IPs"
  value       = local.deploy_web_app ? module.web_app[0].compute_private_ips : null
}

output "web_app_db_endpoint" {
  description = "Web app database endpoint"
  value       = local.deploy_web_app ? module.web_app[0].database_endpoint : null
}

output "web_app_db_port" {
  description = "Web app database port"
  value       = local.deploy_web_app ? module.web_app[0].database_port : null
}

output "web_app_info" {
  description = "Web app blueprint summary"
  value       = local.deploy_web_app ? module.web_app[0].blueprint_info : null
}

# -----------------------------------------------------------------------------
# Data Pipeline Blueprint
# -----------------------------------------------------------------------------

output "pipeline_network_id" {
  description = "Data pipeline network ID"
  value       = local.deploy_data_pipeline ? module.data_pipeline[0].network_id : null
}

output "pipeline_worker_ids" {
  description = "Data pipeline worker instance IDs"
  value       = local.deploy_data_pipeline ? module.data_pipeline[0].worker_instance_ids : null
}

output "pipeline_worker_ips" {
  description = "Data pipeline worker private IPs"
  value       = local.deploy_data_pipeline ? module.data_pipeline[0].worker_private_ips : null
}

output "pipeline_storage_bucket" {
  description = "Data pipeline storage identifier"
  value       = local.deploy_data_pipeline ? module.data_pipeline[0].storage_bucket : null
}

output "pipeline_info" {
  description = "Data pipeline blueprint summary"
  value       = local.deploy_data_pipeline ? module.data_pipeline[0].blueprint_info : null
}

# -----------------------------------------------------------------------------
# Container App Blueprint
# -----------------------------------------------------------------------------

output "container_app_network_id" {
  description = "Container App VNet ID"
  value       = local.deploy_container_app ? module.container_app[0].network_id : null
}

output "container_app_id" {
  description = "Container App ID"
  value       = local.deploy_container_app ? module.container_app[0].container_app_id : null
}

output "container_app_fqdn" {
  description = "Container App FQDN"
  value       = local.deploy_container_app ? module.container_app[0].container_app_fqdn : null
}

output "container_app_url" {
  description = "Container App URL"
  value       = local.deploy_container_app ? module.container_app[0].container_app_url : null
}

output "container_app_storage_endpoint" {
  description = "Container App storage primary blob endpoint"
  value       = local.deploy_container_app ? module.container_app[0].storage_primary_blob_endpoint : null
}

output "container_app_info" {
  description = "Container App blueprint summary"
  value       = local.deploy_container_app ? module.container_app[0].blueprint_info : null
}

# -----------------------------------------------------------------------------
# Virtual Machine Blueprint
# -----------------------------------------------------------------------------

output "vm_network_id" {
  description = "VM blueprint VNet ID"
  value       = local.deploy_virtual_machine ? module.virtual_machine[0].network_id : null
}

output "vm_ids" {
  description = "VM instance IDs"
  value       = local.deploy_virtual_machine ? module.virtual_machine[0].vm_ids : null
}

output "vm_private_ips" {
  description = "VM private IPs"
  value       = local.deploy_virtual_machine ? module.virtual_machine[0].vm_private_ips : null
}

output "vm_keyvault_uri" {
  description = "Key Vault URI (null if Key Vault disabled)"
  value       = local.deploy_virtual_machine ? module.virtual_machine[0].keyvault_uri : null
}

output "vm_info" {
  description = "Virtual Machine blueprint summary"
  value       = local.deploy_virtual_machine ? module.virtual_machine[0].blueprint_info : null
}

# -----------------------------------------------------------------------------
# Network Hub Blueprint
# -----------------------------------------------------------------------------

output "hub_vnet_id" {
  description = "Hub VNet ID"
  value       = local.deploy_hub_network ? module.hub_network[0].vnet_id : null
}

output "hub_vnet_name" {
  description = "Hub VNet name"
  value       = local.deploy_hub_network ? module.hub_network[0].vnet_name : null
}

output "hub_resource_group_name" {
  description = "Hub resource group name"
  value       = local.deploy_hub_network ? module.hub_network[0].resource_group_name : null
}

output "hub_firewall_private_ip" {
  description = "Hub Firewall private IP (null if disabled)"
  value       = local.deploy_hub_network ? module.hub_network[0].firewall_private_ip : null
}

output "hub_info" {
  description = "Network Hub blueprint summary"
  value       = local.deploy_hub_network ? module.hub_network[0].blueprint_info : null
}

# -----------------------------------------------------------------------------
# Metadata — cloud-agnostic
# -----------------------------------------------------------------------------

output "environment_info" {
  description = "Summary of the deployed environment"
  value = {
    env_name        = var.env_name
    env_stage      = var.env_stage
    cloud_provider = var.cloud_provider
    region         = var.cloud_provider == "aws" ? var.aws_region : var.azure_location
    name_prefix    = local.name_prefix
    blueprints     = var.blueprints
  }
}
