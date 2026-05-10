# -----------------------------------------------------------------------------
# Common tags
# -----------------------------------------------------------------------------

locals {
  common_tags = merge(var.extra_tags, {
    ManagedBy = "Terraform"
    EnvName   = var.env_name
    EnvStage  = var.env_stage
    Project   = var.project_name
  })

  # Reserve the last subnet for PostgreSQL delegation if there are 2+ subnets
  app_subnet_count       = length(var.subnet_names) > 1 ? length(var.subnet_names) - 1 : length(var.subnet_names)
  has_delegated_subnet   = length(var.subnet_names) > 1
  delegated_subnet_index = length(var.subnet_names) - 1
}

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------

resource "azurerm_resource_group" "this" {
  name     = var.resource_group
  location = var.location
  tags     = local.common_tags
}

# -----------------------------------------------------------------------------
# Virtual Network
# -----------------------------------------------------------------------------

resource "azurerm_virtual_network" "this" {
  name                = "${var.name_prefix}-vnet"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = var.address_space
  tags                = local.common_tags
}

# -----------------------------------------------------------------------------
# Application Subnets
# -----------------------------------------------------------------------------

resource "azurerm_subnet" "app" {
  count = local.app_subnet_count

  name                 = var.subnet_names[count.index]
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.subnet_prefixes[count.index]]
}

# -----------------------------------------------------------------------------
# Delegated Subnet (for PostgreSQL Flexible Server)
# -----------------------------------------------------------------------------

resource "azurerm_subnet" "delegated" {
  count = local.has_delegated_subnet ? 1 : 0

  name                 = var.subnet_names[local.delegated_subnet_index]
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.subnet_prefixes[local.delegated_subnet_index]]

  delegation {
    name = "postgresql-delegation"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# -----------------------------------------------------------------------------
# Network Security Group
# -----------------------------------------------------------------------------

resource "azurerm_network_security_group" "default" {
  name                = "${var.name_prefix}-default-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "app" {
  count = local.app_subnet_count

  subnet_id                 = azurerm_subnet.app[count.index].id
  network_security_group_id = azurerm_network_security_group.default.id
}

# -----------------------------------------------------------------------------
# Private DNS Zone (for PostgreSQL)
# -----------------------------------------------------------------------------

resource "azurerm_private_dns_zone" "postgres" {
  count = local.has_delegated_subnet ? 1 : 0

  name                = "${var.name_prefix}.private.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  count = local.has_delegated_subnet ? 1 : 0

  name                  = "${var.name_prefix}-postgres-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.postgres[0].name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = azurerm_virtual_network.this.id
}
