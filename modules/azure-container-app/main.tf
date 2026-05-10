# =============================================================================
# Azure Container App Module
#
# Provisions:
#   - Log Analytics Workspace (for Container App Environment)
#   - Container App Environment
#   - Container App with ingress and scaling
# =============================================================================

# -----------------------------------------------------------------------------
# Log Analytics Workspace
# -----------------------------------------------------------------------------

resource "azurerm_log_analytics_workspace" "this" {
  count = var.log_analytics_workspace_id == "" ? 1 : 0

  name                = "${var.name_prefix}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.extra_tags
}

locals {
  log_analytics_workspace_id = (
    var.log_analytics_workspace_id != ""
    ? var.log_analytics_workspace_id
    : azurerm_log_analytics_workspace.this[0].id
  )
}

# -----------------------------------------------------------------------------
# Container App Environment
# -----------------------------------------------------------------------------

resource "azurerm_container_app_environment" "this" {
  name                       = "${var.name_prefix}-cae"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = local.log_analytics_workspace_id
  infrastructure_subnet_id   = var.subnet_id != "" ? var.subnet_id : null
  tags                       = var.extra_tags
}

# -----------------------------------------------------------------------------
# Container App
# -----------------------------------------------------------------------------

resource "azurerm_container_app" "this" {
  name                         = "${var.name_prefix}-ca"
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = var.resource_group_name
  revision_mode                = var.revision_mode
  tags                         = var.extra_tags

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = var.container_name
      image  = var.container_image
      cpu    = var.container_cpu
      memory = var.container_memory

      dynamic "env" {
        for_each = var.env_vars
        content {
          name  = env.value.name
          value = env.value.value
        }
      }
    }
  }

  ingress {
    external_enabled = var.external_ingress
    target_port      = var.target_port
    transport        = var.transport

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}
