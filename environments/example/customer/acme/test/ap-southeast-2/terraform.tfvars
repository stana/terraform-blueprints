# =============================================================================
# Acme — Test
# Blueprint: web-app (inherited from customer-level tfvars)
# NAT, multi-AZ, backup retention etc. are handled by the blueprint's
# environment-aware defaults — no need to set them here.
# =============================================================================

env_stage = "test"

# Networking
vpc_cidr             = "10.11.0.0/16"
availability_zones   = ["eu-west-1a", "eu-west-1b"]
public_subnet_cidrs  = ["10.11.1.0/24", "10.11.2.0/24"]
private_subnet_cidrs = ["10.11.10.0/24", "10.11.11.0/24"]

# Compute
instance_type  = "t3.medium"
instance_count = 2

# Database
enable_database      = true
db_instance_class    = "db.t3.medium"
db_allocated_storage = 20
