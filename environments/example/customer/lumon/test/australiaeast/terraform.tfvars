# =============================================================================
# Lumon — Test (Azure)
# =============================================================================

env_stage = "test"

# Networking
azure_vnet_address_space = ["10.31.0.0/16"]
azure_subnet_prefixes    = ["10.31.1.0/24", "10.31.2.0/24"]
azure_subnet_names       = ["app-subnet", "db-subnet"]

# Compute
azure_vm_size  = "Standard_B2s"
azure_vm_count = 2

# Database
enable_database     = true
azure_db_sku_name   = "GP_Standard_D2s_v3"
azure_db_storage_mb = 65536
