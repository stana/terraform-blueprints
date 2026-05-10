# =============================================================================
# Test Hub — Production (Azure)
# =============================================================================

env_stage = "prod"

# Hub VNet
hub_vnet_address_space = ["10.0.0.0/16"]
hub_subnet_prefixes    = ["10.0.0.0/24"]
hub_subnet_names       = ["shared-subnet"]

# Firewall — AzureFirewallSubnet must be /26 or larger
hub_enable_firewall        = true
hub_firewall_subnet_prefix = "10.0.1.0/26"

# Bastion — AzureBastionSubnet must be /26 or larger
hub_bastion_subnet_prefix = "10.0.2.0/26"
