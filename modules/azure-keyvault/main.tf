# =============================================================================
# Azure Key Vault Module
#
# Provisions:
#   - Azure Key Vault with RBAC authorization
#   - Configurable network ACLs, soft delete, and purge protection
# =============================================================================

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                       = "${var.name_prefix}-kv"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.sku_name
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = var.purge_protection_enabled
  enable_rbac_authorization  = var.enable_rbac_authorization

  network_acls {
    default_action = var.network_default_action
    bypass         = "AzureServices"
  }

  tags = var.extra_tags
}
