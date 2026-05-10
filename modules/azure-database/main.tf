locals {
  # Environment-aware HA and backup settings
  ha_mode = var.env_stage == "prod" ? "ZoneRedundant" : "Disabled"
  backup_retention_days = {
    sandbox = 7
    dev     = 7
    test    = 7
    prod    = 35
  }
  geo_redundant_backup = var.env_stage == "prod" ? true : false
}

# -----------------------------------------------------------------------------
# PostgreSQL Flexible Server
# -----------------------------------------------------------------------------

resource "azurerm_postgresql_flexible_server" "this" {
  name                = "${var.name_prefix}-psql"
  location            = var.location
  resource_group_name = var.resource_group_name

  version  = var.db_version
  sku_name = var.sku_name

  storage_mb = var.storage_mb

  administrator_login    = var.admin_username
  administrator_password = random_password.db.result

  delegated_subnet_id = var.delegated_subnet_id
  private_dns_zone_id = var.private_dns_zone_id

  backup_retention_days        = local.backup_retention_days[var.env_stage]
  geo_redundant_backup_enabled = local.geo_redundant_backup

  dynamic "high_availability" {
    for_each = local.ha_mode != "Disabled" ? [1] : []
    content {
      mode = local.ha_mode
    }
  }

  tags = merge(var.extra_tags, {
    Name = "${var.name_prefix}-psql"
  })

  lifecycle {
    ignore_changes = [
      # Password managed via random_password; don't trigger update
      administrator_password,
      # Allow zone to be auto-selected
      zone,
      high_availability[0].standby_availability_zone,
    ]
  }
}

# -----------------------------------------------------------------------------
# Database
# -----------------------------------------------------------------------------

resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = var.db_name
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# -----------------------------------------------------------------------------
# Random password for admin
# -----------------------------------------------------------------------------

resource "random_password" "db" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
