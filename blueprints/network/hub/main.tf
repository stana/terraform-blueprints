# =============================================================================
# Network Hub Blueprint
#
# A repeatable, opinionated deployment for a hub network in a hub-spoke
# topology. Composes: azure-networking + Azure Firewall + Azure Bastion
#
# Spoke blueprints reference hub outputs via terraform_remote_state to set up
# VNet peering. This blueprint runs in its own subscription and state file.
#
# Environment-aware defaults control SKUs and optional components.
# =============================================================================

locals {
  env_config = {
    sandbox = {
      firewall_sku   = "Standard"
      bastion_sku    = "Basic"
      enable_bastion = false
    }
    dev = {
      firewall_sku   = "Standard"
      bastion_sku    = "Basic"
      enable_bastion = false
    }
    test = {
      firewall_sku   = "Standard"
      bastion_sku    = "Basic"
      enable_bastion = true
    }
    prod = {
      firewall_sku   = "Premium"
      bastion_sku    = "Standard"
      enable_bastion = true
    }
  }

  config = local.env_config[var.env_stage]

  blueprint_tags = merge(var.extra_tags, {
    Blueprint = "hub-network"
  })
}

# =============================================================================
# Azure Networking (Hub VNet)
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
# Azure Firewall
# =============================================================================

resource "azurerm_subnet" "firewall" {
  count = var.enable_firewall ? 1 : 0

  name                 = "AzureFirewallSubnet"
  resource_group_name  = module.networking.resource_group_name
  virtual_network_name = module.networking.vnet_name
  address_prefixes     = [var.firewall_subnet_prefix]
}

resource "azurerm_public_ip" "firewall" {
  count = var.enable_firewall ? 1 : 0

  name                = "${var.name_prefix}-fw-pip"
  location            = var.azure_location
  resource_group_name = module.networking.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.blueprint_tags
}

resource "azurerm_firewall" "this" {
  count = var.enable_firewall ? 1 : 0

  name                = "${var.name_prefix}-fw"
  location            = var.azure_location
  resource_group_name = module.networking.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = local.config.firewall_sku

  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = azurerm_subnet.firewall[0].id
    public_ip_address_id = azurerm_public_ip.firewall[0].id
  }

  tags = local.blueprint_tags
}

# =============================================================================
# Azure Bastion (optional)
# =============================================================================

resource "azurerm_subnet" "bastion" {
  count = local.config.enable_bastion ? 1 : 0

  name                 = "AzureBastionSubnet"
  resource_group_name  = module.networking.resource_group_name
  virtual_network_name = module.networking.vnet_name
  address_prefixes     = [var.bastion_subnet_prefix]
}

resource "azurerm_public_ip" "bastion" {
  count = local.config.enable_bastion ? 1 : 0

  name                = "${var.name_prefix}-bastion-pip"
  location            = var.azure_location
  resource_group_name = module.networking.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.blueprint_tags
}

resource "azurerm_bastion_host" "this" {
  count = local.config.enable_bastion ? 1 : 0

  name                = "${var.name_prefix}-bastion"
  location            = var.azure_location
  resource_group_name = module.networking.resource_group_name
  sku                 = local.config.bastion_sku

  ip_configuration {
    name                 = "bastion-ipconfig"
    subnet_id            = azurerm_subnet.bastion[0].id
    public_ip_address_id = azurerm_public_ip.bastion[0].id
  }

  tags = local.blueprint_tags
}
