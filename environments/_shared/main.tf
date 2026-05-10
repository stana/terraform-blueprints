# =============================================================================
# main.tf — Orchestrator
#
# This file is the entry point. It decides WHAT to deploy based on the
# `blueprints` variable. Each blueprint is a higher-level composition of modules.
#
# Deployment model:
#   tfvars sets:  blueprints = ["web-app"]
#   main.tf:      calls blueprints/web-app/ which internally composes modules
#
# You can deploy multiple blueprints in the same environment (e.g. a web-app
# AND a data-pipeline), or just one.
# =============================================================================

locals {
  name_prefix = "${var.env_name}-${var.env_stage}"

  is_aws   = var.cloud_provider == "aws"
  is_azure = var.cloud_provider == "azure"

  # Which blueprints are enabled
  deploy_web_app       = contains(var.blueprints, "web-app")
  deploy_data_pipeline = contains(var.blueprints, "data-pipeline")
  deploy_container_app = contains(var.blueprints, "api-app")
  deploy_virtual_machine = contains(var.blueprints, "appliance")
  deploy_hub_network     = contains(var.blueprints, "hub-network")
}

# =============================================================================
# Blueprint: web-app
# =============================================================================

module "web_app" {
  source = "../../blueprints/services/web-app"
  count  = local.deploy_web_app ? 1 : 0

  # Identity
  name_prefix    = local.name_prefix
  env_stage      = var.env_stage
  cloud_provider = var.cloud_provider
  env_name       = var.env_name
  project_name   = var.project_name

  # AWS networking
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  # AWS compute
  instance_type  = var.instance_type
  instance_count = var.instance_count
  ami_id         = var.ami_id
  key_name       = var.key_name

  # AWS database
  db_engine            = var.db_engine
  db_engine_version    = var.db_engine_version
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage

  # Azure networking
  azure_location           = var.azure_location
  azure_vnet_address_space = var.azure_vnet_address_space
  azure_subnet_prefixes    = var.azure_subnet_prefixes
  azure_subnet_names       = var.azure_subnet_names

  # Azure compute
  azure_vm_size        = var.azure_vm_size
  azure_vm_count       = var.azure_vm_count
  azure_admin_username = var.azure_admin_username

  # Azure database
  azure_db_sku_name   = var.azure_db_sku_name
  azure_db_storage_mb = var.azure_db_storage_mb
  azure_db_version    = var.azure_db_version

  # Application-level config
  enable_database = var.enable_database
  db_name         = var.db_name
  db_username     = var.db_username
  enable_cdn      = var.enable_cdn
  enable_waf      = var.enable_waf
  extra_tags      = var.extra_tags
}

# =============================================================================
# Blueprint: data-pipeline
# =============================================================================

module "data_pipeline" {
  source = "../../blueprints/data/pipeline"
  count  = local.deploy_data_pipeline ? 1 : 0

  # Identity
  name_prefix    = "${local.name_prefix}-pipeline"
  env_stage      = var.env_stage
  cloud_provider = var.cloud_provider
  env_name       = var.env_name
  project_name   = var.project_name

  # AWS networking (separate CIDR to avoid overlap with web-app)
  vpc_cidr             = var.pipeline_vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.pipeline_public_subnet_cidrs
  private_subnet_cidrs = var.pipeline_private_subnet_cidrs

  # AWS compute
  worker_instance_type = var.pipeline_worker_instance_type
  worker_count         = var.pipeline_worker_count
  ami_id               = var.ami_id
  key_name             = var.key_name

  # Azure networking
  azure_location           = var.azure_location
  azure_vnet_address_space = var.pipeline_azure_vnet_address_space
  azure_subnet_prefixes    = var.pipeline_azure_subnet_prefixes
  azure_subnet_names       = var.pipeline_azure_subnet_names

  # Azure compute
  azure_worker_vm_size = var.pipeline_azure_worker_vm_size
  azure_worker_count   = var.pipeline_worker_count
  azure_admin_username = var.azure_admin_username

  # Pipeline-specific config
  storage_bucket_name = var.pipeline_storage_bucket_name
  enable_versioning   = var.pipeline_enable_versioning
  data_retention_days = var.pipeline_data_retention_days
  enable_encryption   = var.pipeline_enable_encryption
  extra_tags          = var.extra_tags
}

# =============================================================================
# Blueprint: api-app (Azure only)
# =============================================================================

module "container_app" {
  source = "../../blueprints/services/api-app"
  count  = local.deploy_container_app ? 1 : 0

  # Identity
  name_prefix    = "${local.name_prefix}-ca"
  env_stage      = var.env_stage
  cloud_provider = var.cloud_provider
  env_name       = var.env_name
  project_name   = var.project_name

  # Azure networking
  azure_location           = var.azure_location
  azure_vnet_address_space = var.container_app_vnet_address_space
  azure_subnet_prefixes    = var.container_app_subnet_prefixes
  azure_subnet_names       = var.container_app_subnet_names

  # Container App config
  container_image      = var.container_app_image
  container_name       = var.container_app_container_name
  container_cpu        = var.container_app_cpu
  container_memory     = var.container_app_memory
  container_min_replicas = var.container_app_min_replicas
  container_max_replicas = var.container_app_max_replicas
  target_port          = var.container_app_target_port
  external_ingress     = var.container_app_external_ingress
  revision_mode        = var.container_app_revision_mode
  container_env_vars   = var.container_app_env_vars

  # Storage
  enable_storage         = var.container_app_enable_storage
  storage_account_name   = var.container_app_storage_account_name
  storage_container_name = var.container_app_storage_container_name
  extra_tags             = var.extra_tags
}

# =============================================================================
# Blueprint: appliance (Azure only)
# =============================================================================

module "virtual_machine" {
  source = "../../blueprints/services/appliance"
  count  = local.deploy_virtual_machine ? 1 : 0

  # Identity
  name_prefix    = "${local.name_prefix}-vm"
  env_stage      = var.env_stage
  cloud_provider = var.cloud_provider
  env_name       = var.env_name
  project_name   = var.project_name

  # Azure networking
  enable_networking        = var.vm_enable_networking
  azure_location           = var.azure_location
  azure_vnet_address_space = var.vm_vnet_address_space
  azure_subnet_prefixes    = var.vm_subnet_prefixes
  azure_subnet_names       = var.vm_subnet_names
  external_subnet_id       = var.vm_external_subnet_id
  external_resource_group_name = var.vm_external_resource_group_name

  # VM config
  azure_vm_size        = var.vm_azure_vm_size
  azure_vm_count       = var.vm_azure_vm_count
  azure_admin_username = var.azure_admin_username

  # Key Vault
  enable_keyvault = var.vm_enable_keyvault
  keyvault_sku    = var.vm_keyvault_sku
  extra_tags      = var.extra_tags
}

# =============================================================================
# Blueprint: hub-network (Azure only)
# =============================================================================

module "hub_network" {
  source = "../../blueprints/network/hub"
  count  = local.deploy_hub_network ? 1 : 0

  # Identity
  name_prefix    = "${local.name_prefix}-hub"
  env_stage      = var.env_stage
  cloud_provider = var.cloud_provider
  env_name       = var.env_name
  project_name   = var.project_name

  # Azure networking
  azure_location           = var.azure_location
  azure_vnet_address_space = var.hub_vnet_address_space
  azure_subnet_prefixes    = var.hub_subnet_prefixes
  azure_subnet_names       = var.hub_subnet_names

  # Firewall
  enable_firewall        = var.hub_enable_firewall
  firewall_subnet_prefix = var.hub_firewall_subnet_prefix

  # Bastion
  bastion_subnet_prefix = var.hub_bastion_subnet_prefix
  extra_tags            = var.extra_tags
}
