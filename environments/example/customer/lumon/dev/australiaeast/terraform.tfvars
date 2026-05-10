# =============================================================================
# Lumon — Development (Azure)
# =============================================================================

env_stage = "dev"

# Networking
azure_vnet_address_space = ["10.30.0.0/16"]
azure_subnet_prefixes    = ["10.30.1.0/24", "10.30.2.0/24"]
azure_subnet_names       = ["app-subnet", "db-subnet"]

# Compute
azure_vm_size  = "Standard_B1s"
azure_vm_count = 1

# Database
enable_database    = true
azure_db_sku_name  = "B_Standard_B1ms"
azure_db_storage_mb = 32768
