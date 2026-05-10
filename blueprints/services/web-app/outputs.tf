# =============================================================================
# Web App Blueprint — Outputs
#
# Cloud-agnostic output interface. Consumers get the same output structure
# regardless of whether the blueprint deployed to AWS or Azure.
# =============================================================================

# -- Networking ---------------------------------------------------------------

output "network_id" {
  description = "Network ID (VPC ID on AWS, VNet ID on Azure)"
  value       = local.is_aws ? module.aws_networking[0].vpc_id : (local.is_azure ? module.az_networking[0].vnet_id : null)
}

output "subnet_ids" {
  description = "Subnet IDs where compute runs"
  value       = local.is_aws ? module.aws_networking[0].private_subnet_ids : (local.is_azure ? module.az_networking[0].subnet_ids : null)
}

# -- Compute -----------------------------------------------------------------

output "compute_instance_ids" {
  description = "Compute instance IDs"
  value       = local.is_aws ? module.aws_compute[0].instance_ids : (local.is_azure ? module.az_compute[0].vm_ids : null)
}

output "compute_private_ips" {
  description = "Compute instance private IPs"
  value       = local.is_aws ? module.aws_compute[0].instance_private_ips : (local.is_azure ? module.az_compute[0].private_ips : null)
}

# -- Database -----------------------------------------------------------------

output "database_endpoint" {
  description = "Database connection endpoint"
  value = (
    var.enable_database
    ? (local.is_aws ? module.aws_database[0].endpoint : (local.is_azure ? module.az_database[0].server_fqdn : null))
    : null
  )
}

output "database_port" {
  description = "Database port"
  value = (
    var.enable_database
    ? (local.is_aws ? module.aws_database[0].port : (local.is_azure ? 5432 : null))
    : null
  )
}

# -- Blueprint metadata -----------------------------------------------------------

output "blueprint_info" {
  description = "Blueprint deployment summary"
  value = {
    blueprint      = "web-app"
    name_prefix    = var.name_prefix
    env_stage      = var.env_stage
    cloud_provider = var.cloud_provider
    features = {
      database = var.enable_database
      cdn      = var.enable_cdn
      waf      = var.enable_waf
      ssl      = var.enable_ssl
    }
  }
}
