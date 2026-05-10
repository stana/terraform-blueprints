# =============================================================================
# Azure Container App Module — Outputs
# =============================================================================

output "container_app_id" {
  description = "ID of the Container App"
  value       = azurerm_container_app.this.id
}

output "container_app_name" {
  description = "Name of the Container App"
  value       = azurerm_container_app.this.name
}

output "container_app_fqdn" {
  description = "FQDN of the Container App"
  value       = azurerm_container_app.this.ingress[0].fqdn
}

output "container_app_url" {
  description = "URL of the Container App"
  value       = "https://${azurerm_container_app.this.ingress[0].fqdn}"
}

output "environment_id" {
  description = "ID of the Container App Environment"
  value       = azurerm_container_app_environment.this.id
}

output "environment_name" {
  description = "Name of the Container App Environment"
  value       = azurerm_container_app_environment.this.name
}
