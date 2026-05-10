# =============================================================================
# Container App Blueprint — Outputs
#
# Cloud-agnostic output interface for the Container App blueprint.
# =============================================================================

# -- Networking ---------------------------------------------------------------

output "network_id" {
  description = "VNet ID"
  value       = module.networking.vnet_id
}

output "subnet_ids" {
  description = "Subnet IDs"
  value       = module.networking.subnet_ids
}

# -- Container App ------------------------------------------------------------

output "container_app_id" {
  description = "Container App ID"
  value       = module.container_app.container_app_id
}

output "container_app_name" {
  description = "Container App name"
  value       = module.container_app.container_app_name
}

output "container_app_fqdn" {
  description = "Container App FQDN"
  value       = module.container_app.container_app_fqdn
}

output "container_app_url" {
  description = "Container App URL"
  value       = module.container_app.container_app_url
}

output "environment_id" {
  description = "Container App Environment ID"
  value       = module.container_app.environment_id
}

# -- Storage ------------------------------------------------------------------

output "storage_account_name" {
  description = "Storage account name (null if storage disabled)"
  value       = var.enable_storage ? azurerm_storage_account.this[0].name : null
}

output "storage_account_id" {
  description = "Storage account ID (null if storage disabled)"
  value       = var.enable_storage ? azurerm_storage_account.this[0].id : null
}

output "storage_primary_blob_endpoint" {
  description = "Primary blob endpoint (null if storage disabled)"
  value       = var.enable_storage ? azurerm_storage_account.this[0].primary_blob_endpoint : null
}

# -- Blueprint metadata -----------------------------------------------------------

output "blueprint_info" {
  description = "Blueprint deployment summary"
  value = {
    blueprint      = "api-app"
    name_prefix    = var.name_prefix
    env_stage      = var.env_stage
    cloud_provider = var.cloud_provider
    container = {
      image    = var.container_image
      cpu      = local.config.container_cpu
      memory   = local.config.container_mem
      replicas = "${local.config.min_replicas}-${local.config.max_replicas}"
    }
    features = {
      storage = var.enable_storage
    }
  }
}
