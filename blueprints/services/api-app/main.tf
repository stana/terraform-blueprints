# =============================================================================
# Container App Blueprint
#
# A repeatable, opinionated deployment for Azure Container Apps.
# Composes: azure-networking + azure-container-app
#
# This blueprint encodes environment-aware defaults — prod gets higher min
# replicas, more resources, and multiple revision mode.
# =============================================================================

locals {
  # Environment-aware defaults — the blueprint's "opinions"
  env_config = {
    sandbox = {
      min_replicas   = 0
      max_replicas   = 1
      container_cpu  = 0.25
      container_mem  = "0.5Gi"
      revision_mode  = "Single"
    }
    dev = {
      min_replicas   = 0
      max_replicas   = 1
      container_cpu  = 0.25
      container_mem  = "0.5Gi"
      revision_mode  = "Single"
    }
    test = {
      min_replicas   = 1
      max_replicas   = 2
      container_cpu  = 0.5
      container_mem  = "1Gi"
      revision_mode  = "Single"
    }
    prod = {
      min_replicas   = 2
      max_replicas   = 10
      container_cpu  = 1.0
      container_mem  = "2Gi"
      revision_mode  = "Multiple"
    }
  }

  config = local.env_config[var.env_stage]

  # Storage account name must be 3-24 chars, lowercase alphanumeric only
  storage_account_name = var.storage_account_name != "" ? var.storage_account_name : replace("${var.name_prefix}stor", "-", "")

  blueprint_tags = merge(var.extra_tags, {
    Blueprint = "api-app"
  })
}

# =============================================================================
# Azure Networking
# =============================================================================

module "networking" {
  source = "../../../modules/azure-networking"

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
# Azure Container App
# =============================================================================

module "container_app" {
  source = "../../../modules/azure-container-app"

  name_prefix         = var.name_prefix
  location            = var.azure_location
  resource_group_name = module.networking.resource_group_name
  subnet_id           = length(module.networking.subnet_ids) > 0 ? module.networking.subnet_ids[0] : ""
  container_image     = var.container_image
  container_name      = var.container_name
  container_cpu       = local.config.container_cpu
  container_memory    = local.config.container_mem
  min_replicas        = local.config.min_replicas
  max_replicas        = local.config.max_replicas
  target_port         = var.target_port
  external_ingress    = var.external_ingress
  transport           = "auto"
  revision_mode       = local.config.revision_mode
  env_vars            = var.container_env_vars
  extra_tags          = local.blueprint_tags
}

# =============================================================================
# Azure Storage Account (optional)
# =============================================================================

resource "azurerm_storage_account" "this" {
  count = var.enable_storage ? 1 : 0

  name                     = local.storage_account_name
  resource_group_name      = module.networking.resource_group_name
  location                 = var.azure_location
  account_tier             = "Standard"
  account_replication_type = var.env_stage == "prod" ? "GRS" : "LRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }
  }

  tags = local.blueprint_tags
}

resource "azurerm_storage_container" "data" {
  count = var.enable_storage ? 1 : 0

  name                  = var.storage_container_name
  storage_account_id    = azurerm_storage_account.this[0].id
  container_access_type = "private"
}
