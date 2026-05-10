# =============================================================================
# Acme — Production
# Blueprint: web-app (inherited from customer-level tfvars)
# NAT HA, multi-AZ DB, deletion protection, 30-day backups etc.
# are automatically applied by the blueprint for env_stage=prod.
# =============================================================================

env_stage = "prod"

# Networking
vpc_cidr             = "10.12.0.0/16"
availability_zones   = ["apse2-az1", "apse2-az2", "apse2-az3"]
public_subnet_cidrs  = ["10.12.1.0/24", "10.12.2.0/24", "10.12.3.0/24"]
private_subnet_cidrs = ["10.12.10.0/24", "10.12.11.0/24", "10.12.12.0/24"]

# Compute
instance_type  = "t3.xlarge"
instance_count = 3

# Database
enable_database      = true
db_instance_class    = "db.r6g.large"
db_allocated_storage = 100

# Features
enable_monitoring = true
enable_waf        = true
