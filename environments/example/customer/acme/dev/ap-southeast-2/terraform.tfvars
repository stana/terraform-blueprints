# =============================================================================
# Acme — Development
# =============================================================================

env_stage = "dev"

# Networking
vpc_cidr             = "10.10.0.0/16"
availability_zones   = ["apse2-az1", "apse2-az2"]
public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs = ["10.10.10.0/24", "10.10.11.0/24"]
# Compute
instance_type  = "t3.small"
instance_count = 1

# Database
enable_database            = true
db_instance_class          = "db.t3.micro"
db_allocated_storage       = 10
db_multi_az                = false
db_deletion_protection     = false
db_backup_retention_period = 1
