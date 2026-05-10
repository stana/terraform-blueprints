# =============================================================================
# Data Pipeline Blueprint — Outputs
# =============================================================================

output "network_id" {
  description = "Network ID (VPC or VNet)"
  value       = local.is_aws ? module.aws_networking[0].vpc_id : (local.is_azure ? module.az_networking[0].vnet_id : null)
}

output "worker_instance_ids" {
  description = "Worker compute instance IDs"
  value       = local.is_aws ? module.aws_workers[0].instance_ids : (local.is_azure ? module.az_workers[0].vm_ids : null)
}

output "worker_private_ips" {
  description = "Worker private IPs"
  value       = local.is_aws ? module.aws_workers[0].instance_private_ips : (local.is_azure ? module.az_workers[0].private_ips : null)
}

output "storage_bucket" {
  description = "Data storage identifier (S3 bucket name or Azure Storage Account name)"
  value       = local.is_aws ? aws_s3_bucket.data[0].id : (local.is_azure ? azurerm_storage_account.data[0].name : null)
}

output "storage_arn" {
  description = "Data storage ARN (AWS) or ID (Azure)"
  value       = local.is_aws ? aws_s3_bucket.data[0].arn : (local.is_azure ? azurerm_storage_account.data[0].id : null)
}

output "blueprint_info" {
  description = "Blueprint deployment summary"
  value = {
    blueprint      = "data-pipeline"
    name_prefix    = var.name_prefix
    env_stage      = var.env_stage
    cloud_provider = var.cloud_provider
    features = {
      versioning     = var.enable_versioning
      encryption     = var.enable_encryption
      retention_days = var.data_retention_days
    }
  }
}
