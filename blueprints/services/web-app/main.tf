# =============================================================================
# Web App Blueprint
#
# A repeatable, opinionated deployment for web applications.
# Composes: networking + compute + database (+ optional CDN/WAF)
#
# This blueprint encodes environment-aware defaults so consumers don't need to
# know the details — just set "env_stage = prod" and the blueprint enables
# multi-AZ, NAT gateways, deletion protection, etc.
# =============================================================================

locals {
  is_aws   = var.cloud_provider == "aws"
  is_azure = var.cloud_provider == "azure"

  # Environment-aware defaults — the blueprint's "opinions"
  env_config = {
    sandbox = {
      enable_nat     = false
      single_nat     = true
      db_multi_az    = false
      db_protection  = false
      db_backup_days = 1
    }
    dev = {
      enable_nat     = false
      single_nat     = true
      db_multi_az    = false
      db_protection  = false
      db_backup_days = 1
    }
    test = {
      enable_nat     = true
      single_nat     = true
      db_multi_az    = false
      db_protection  = false
      db_backup_days = 3
    }
    prod = {
      enable_nat     = true
      single_nat     = false
      db_multi_az    = true
      db_protection  = true
      db_backup_days = 30
    }
  }

  config = local.env_config[var.env_stage]

  blueprint_tags = merge(var.extra_tags, {
    Blueprint = "web-app"
  })
}

# =============================================================================
# AWS Resources
# =============================================================================

module "aws_networking" {
  source = "../../../modules/aws-networking"
  count  = local.is_aws ? 1 : 0

  name_prefix          = var.name_prefix
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = local.config.enable_nat
  single_nat_gateway   = local.config.single_nat
  extra_tags           = local.blueprint_tags
}

module "aws_compute" {
  source = "../../../modules/aws-compute"
  count  = local.is_aws ? 1 : 0

  name_prefix    = var.name_prefix
  instance_type  = var.instance_type
  instance_count = var.instance_count
  ami_id         = var.ami_id
  key_name       = var.key_name
  subnet_ids     = module.aws_networking[0].private_subnet_ids
  vpc_id         = module.aws_networking[0].vpc_id
  extra_tags     = local.blueprint_tags
}

module "aws_database" {
  source = "../../../modules/aws-database"
  count  = local.is_aws && var.enable_database ? 1 : 0

  name_prefix             = var.name_prefix
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  db_name                 = var.db_name
  username                = var.db_username
  multi_az                = local.config.db_multi_az
  deletion_protection     = local.config.db_protection
  backup_retention_period = local.config.db_backup_days
  subnet_ids              = module.aws_networking[0].private_subnet_ids
  vpc_id                  = module.aws_networking[0].vpc_id
  extra_tags              = local.blueprint_tags
}

# =============================================================================
# Azure Resources
# =============================================================================

module "az_networking" {
  source = "../../../modules/azure-networking"
  count  = local.is_azure ? 1 : 0

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

module "az_compute" {
  source = "../../../modules/azure-compute"
  count  = local.is_azure ? 1 : 0

  name_prefix         = var.name_prefix
  location            = var.azure_location
  resource_group_name = module.az_networking[0].resource_group_name
  vm_size             = var.azure_vm_size
  vm_count            = var.azure_vm_count
  admin_username      = var.azure_admin_username
  subnet_id           = module.az_networking[0].subnet_ids[0]
  extra_tags          = local.blueprint_tags
}

module "az_database" {
  source = "../../../modules/azure-database"
  count  = local.is_azure && var.enable_database ? 1 : 0

  name_prefix         = var.name_prefix
  location            = var.azure_location
  resource_group_name = module.az_networking[0].resource_group_name
  delegated_subnet_id = module.az_networking[0].delegated_subnet_id
  private_dns_zone_id = module.az_networking[0].private_dns_zone_id
  sku_name            = var.azure_db_sku_name
  storage_mb          = var.azure_db_storage_mb
  db_version          = var.azure_db_version
  db_name             = var.db_name
  admin_username      = var.db_username
  env_stage           = var.env_stage
  extra_tags          = local.blueprint_tags
}
