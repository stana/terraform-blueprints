# =============================================================================
# Virtual Machine Blueprint
#
# A repeatable, opinionated deployment for Azure Virtual Machines.
# Composes: azure-networking (optional) + azure-compute + azure-keyvault (optional)
#
# Environment-aware defaults control VM sizing.
# Networking can be created by the blueprint or supplied externally.
# =============================================================================

locals {
  env_config = {
    sandbox = {
      vm_size              = "Standard_B1s"
      purge_protection     = false
      kv_soft_delete_days  = 7
    }
    dev = {
      vm_size              = "Standard_B1s"
      purge_protection     = false
      kv_soft_delete_days  = 7
    }
    test = {
      vm_size              = "Standard_B2s"
      purge_protection     = false
      kv_soft_delete_days  = 7
    }
    prod = {
      vm_size              = "Standard_D4s_v3"
      purge_protection     = true
      kv_soft_delete_days  = 90
    }
  }

  config = local.env_config[var.env_stage]

  # Resolve resource group and subnet depending on whether networking is managed
  resource_group_name = var.enable_networking ? module.networking[0].resource_group_name : var.external_resource_group_name
  subnet_id           = var.enable_networking ? module.networking[0].subnet_ids[0] : var.external_subnet_id

  blueprint_tags = merge(var.extra_tags, {
    Blueprint = "appliance"
  })
}

# =============================================================================
# Azure Networking (optional)
# =============================================================================

module "networking" {
  source = "../../../modules/azure-networking"
  count  = var.enable_networking ? 1 : 0

  name_prefix     = var.name_prefix
  location        = var.azure_location
  resource_group  = "${var.name_prefix}-rg"
  address_space   = var.azure_vnet_address_space
  subnet_prefixes = var.azure_subnet_prefixes
  subnet_names    = var.azure_subnet_names
  env_name        = var.env_name
  env_stage       = var.env_stage
  project_name    = var.project_name
  extra_tags      = local.blueprint_tags
}

# =============================================================================
# Azure Virtual Machines
# =============================================================================

module "compute" {
  source = "../../../modules/azure-compute"

  name_prefix         = var.name_prefix
  location            = var.azure_location
  resource_group_name = local.resource_group_name
  vm_size             = var.azure_vm_size
  vm_count            = var.azure_vm_count
  admin_username      = var.azure_admin_username
  subnet_id           = local.subnet_id
  extra_tags          = local.blueprint_tags
}

# =============================================================================
# Azure Key Vault (optional)
# =============================================================================

module "keyvault" {
  source = "../../../modules/azure-keyvault"
  count  = var.enable_keyvault ? 1 : 0

  name_prefix              = var.name_prefix
  location                 = var.azure_location
  resource_group_name      = local.resource_group_name
  sku_name                 = var.keyvault_sku
  soft_delete_retention_days = local.config.kv_soft_delete_days
  purge_protection_enabled = local.config.purge_protection
  extra_tags               = local.blueprint_tags
}
