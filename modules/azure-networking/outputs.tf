output "resource_group_name" {
  description = "The resource group name"
  value       = azurerm_resource_group.this.name
}

output "resource_group_location" {
  description = "The resource group location"
  value       = azurerm_resource_group.this.location
}

output "vnet_id" {
  description = "The VNet ID"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "The VNet name"
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "List of application subnet IDs"
  value       = azurerm_subnet.app[*].id
}

output "delegated_subnet_id" {
  description = "Delegated subnet ID for PostgreSQL (null if not created)"
  value       = local.has_delegated_subnet ? azurerm_subnet.delegated[0].id : null
}

output "private_dns_zone_id" {
  description = "Private DNS zone ID for PostgreSQL (null if not created)"
  value       = local.has_delegated_subnet ? azurerm_private_dns_zone.postgres[0].id : null
}

output "nsg_id" {
  description = "Default network security group ID"
  value       = azurerm_network_security_group.default.id
}
