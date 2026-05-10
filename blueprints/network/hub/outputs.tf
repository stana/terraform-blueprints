# =============================================================================
# Network Hub Blueprint — Outputs
#
# These outputs are consumed by spoke blueprints via terraform_remote_state.
# =============================================================================

# -- Networking ---------------------------------------------------------------

output "resource_group_name" {
  description = "Hub resource group name"
  value       = module.networking.resource_group_name
}

output "vnet_id" {
  description = "Hub VNet ID"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "Hub VNet name"
  value       = module.networking.vnet_name
}

output "subnet_ids" {
  description = "Hub subnet IDs (app subnets only, excludes Firewall/Bastion)"
  value       = module.networking.subnet_ids
}

# -- Firewall -----------------------------------------------------------------

output "firewall_id" {
  description = "Azure Firewall ID (null if disabled)"
  value       = var.enable_firewall ? azurerm_firewall.this[0].id : null
}

output "firewall_private_ip" {
  description = "Azure Firewall private IP (null if disabled)"
  value       = var.enable_firewall ? azurerm_firewall.this[0].ip_configuration[0].private_ip_address : null
}

output "firewall_public_ip" {
  description = "Azure Firewall public IP (null if disabled)"
  value       = var.enable_firewall ? azurerm_public_ip.firewall[0].ip_address : null
}

# -- Bastion ------------------------------------------------------------------

output "bastion_id" {
  description = "Azure Bastion ID (null if disabled)"
  value       = local.config.enable_bastion ? azurerm_bastion_host.this[0].id : null
}

# -- Blueprint metadata -----------------------------------------------------------

output "blueprint_info" {
  description = "Blueprint deployment summary"
  value = {
    blueprint      = "hub-network"
    name_prefix    = var.name_prefix
    env_stage      = var.env_stage
    cloud_provider = var.cloud_provider
    features = {
      firewall = var.enable_firewall
      bastion  = local.config.enable_bastion
    }
  }
}
