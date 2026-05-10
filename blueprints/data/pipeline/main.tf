# =============================================================================
# Data Pipeline Blueprint
#
# A repeatable deployment for data processing workloads.
# Composes: networking + compute (workers) + object storage
#
# Designed for ETL jobs, batch processing, data lake ingestion, etc.
# Workers get NAT gateway access (to pull data from external sources).
# Storage includes lifecycle rules and optional versioning.
# =============================================================================

locals {
  is_aws   = var.cloud_provider == "aws"
  is_azure = var.cloud_provider == "azure"

  bucket_name = var.storage_bucket_name != "" ? var.storage_bucket_name : "${var.name_prefix}-data"

  env_config = {
    sandbox = {
      enable_nat = true
      single_nat = true
    }
    dev = {
      enable_nat = true  # Workers need outbound access
      single_nat = true
    }
    test = {
      enable_nat = true
      single_nat = true
    }
    prod = {
      enable_nat = true
      single_nat = false  # HA NAT for production
    }
  }

  config = local.env_config[var.env_stage]

  blueprint_tags = merge(var.extra_tags, {
    Blueprint = "data-pipeline"
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

module "aws_workers" {
  source = "../../../modules/aws-compute"
  count  = local.is_aws ? 1 : 0

  name_prefix    = "${var.name_prefix}-worker"
  instance_type  = var.worker_instance_type
  instance_count = var.worker_count
  ami_id         = var.ami_id
  key_name       = var.key_name
  subnet_ids     = module.aws_networking[0].private_subnet_ids
  vpc_id         = module.aws_networking[0].vpc_id
  extra_tags     = local.blueprint_tags
}

# -- S3 Bucket for data storage -----------------------------------------------

resource "aws_s3_bucket" "data" {
  count  = local.is_aws ? 1 : 0
  bucket = local.bucket_name
  tags   = local.blueprint_tags
}

resource "aws_s3_bucket_versioning" "data" {
  count  = local.is_aws ? 1 : 0
  bucket = aws_s3_bucket.data[0].id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  count  = local.is_aws && var.enable_encryption ? 1 : 0
  bucket = aws_s3_bucket.data[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "data" {
  count  = local.is_aws ? 1 : 0
  bucket = aws_s3_bucket.data[0].id

  rule {
    id     = "archive-old-data"
    status = "Enabled"

    filter {
      prefix = "processed/"
    }

    transition {
      days          = var.data_retention_days
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "data" {
  count  = local.is_aws ? 1 : 0
  bucket = aws_s3_bucket.data[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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

module "az_workers" {
  source = "../../../modules/azure-compute"
  count  = local.is_azure ? 1 : 0

  name_prefix         = "${var.name_prefix}-worker"
  location            = var.azure_location
  resource_group_name = module.az_networking[0].resource_group_name
  vm_size             = var.azure_worker_vm_size
  vm_count            = var.azure_worker_count
  admin_username      = var.azure_admin_username
  subnet_id           = module.az_networking[0].subnet_ids[0]
  extra_tags          = local.blueprint_tags
}

# -- Azure Storage Account for data -------------------------------------------

resource "azurerm_storage_account" "data" {
  count = local.is_azure ? 1 : 0

  name                     = replace("${var.name_prefix}data", "-", "")
  resource_group_name      = module.az_networking[0].resource_group_name
  location                 = var.azure_location
  account_tier             = "Standard"
  account_replication_type = var.env_stage == "prod" ? "GRS" : "LRS"

  blob_properties {
    versioning_enabled = var.enable_versioning

    delete_retention_policy {
      days = 7
    }
  }

  tags = local.blueprint_tags
}

resource "azurerm_storage_container" "raw" {
  count                 = local.is_azure ? 1 : 0
  name                  = "raw"
  storage_account_id    = azurerm_storage_account.data[0].id
  container_access_type = "private"
}

resource "azurerm_storage_container" "processed" {
  count                 = local.is_azure ? 1 : 0
  name                  = "processed"
  storage_account_id    = azurerm_storage_account.data[0].id
  container_access_type = "private"
}
