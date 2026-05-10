# =============================================================================
# Virtual Machine Blueprint — Outputs
# =============================================================================

# -- Networking ---------------------------------------------------------------

output "network_id" {
  description = "VNet ID (null if networking not managed by this blueprint)"
  value       = var.enable_networking ? module.networking[0].vnet_id : null
}

output "subnet_ids" {
  description = "Subnet IDs (null if networking not managed by this blueprint)"
  value       = var.enable_networking ? module.networking[0].subnet_ids : null
}

# -- Compute -----------------------------------------------------------------

output "vm_ids" {
  description = "Virtual Machine IDs"
  value       = module.compute.vm_ids
}

output "vm_private_ips" {
  description = "Virtual Machine private IPs"
  value       = module.compute.private_ips
}

# -- Key Vault ----------------------------------------------------------------

output "keyvault_id" {
  description = "Key Vault ID (null if Key Vault disabled)"
  value       = var.enable_keyvault ? module.keyvault[0].key_vault_id : null
}

output "keyvault_name" {
  description = "Key Vault name (null if Key Vault disabled)"
  value       = var.enable_keyvault ? module.keyvault[0].key_vault_name : null
}

output "keyvault_uri" {
  description = "Key Vault URI (null if Key Vault disabled)"
  value       = var.enable_keyvault ? module.keyvault[0].key_vault_uri : null
}

# -- Blueprint metadata -----------------------------------------------------------

output "blueprint_info" {
  description = "Blueprint deployment summary"
  value = {
    blueprint      = "appliance"
    name_prefix    = var.name_prefix
    env_stage      = var.env_stage
    cloud_provider = var.cloud_provider
    vm_count       = var.azure_vm_count
    features = {
      networking = var.enable_networking
      keyvault   = var.enable_keyvault
    }
  }
}
