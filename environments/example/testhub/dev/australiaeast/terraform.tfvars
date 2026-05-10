# =============================================================================
# Test Hub — Development (Azure)
# =============================================================================

env_stage = "dev"

# Hub VNet
hub_vnet_address_space = ["10.0.0.0/16"]
hub_subnet_prefixes    = ["10.0.0.0/24"]
hub_subnet_names       = ["shared-subnet"]

# Firewall
hub_enable_firewall        = true
hub_firewall_subnet_prefix = "10.0.1.0/26"

# Bastion (disabled by env_config for dev)
hub_bastion_subnet_prefix = "10.0.2.0/26"
