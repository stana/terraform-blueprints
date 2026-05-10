# =============================================================================
# Lumon — Production (Azure)
# =============================================================================

env_stage = "prod"

# Networking
azure_vnet_address_space = ["10.32.0.0/16"]
azure_subnet_prefixes    = ["10.32.1.0/24", "10.32.2.0/24", "10.32.3.0/24"]
azure_subnet_names       = ["app-subnet-1", "app-subnet-2", "db-subnet"]

# Compute
azure_vm_size  = "Standard_D4s_v3"
azure_vm_count = 3

# Database
enable_database     = true
azure_db_sku_name   = "GP_Standard_D4s_v3"
azure_db_storage_mb = 131072

# Features
enable_monitoring = true
enable_waf        = true
