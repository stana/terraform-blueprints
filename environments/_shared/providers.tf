# -----------------------------------------------------------------------------
# AWS Provider — only active when cloud_provider == "aws"
#
# When cloud_provider != "aws", dummy credentials and skip flags prevent
# Terraform from attempting real AWS authentication.
# -----------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region

  # Prevent AWS credential lookup when not using AWS
  skip_credentials_validation = var.cloud_provider != "aws"
  skip_requesting_account_id  = var.cloud_provider != "aws"
  skip_metadata_api_check     = var.cloud_provider != "aws"
  skip_region_validation      = var.cloud_provider != "aws"

  # Dummy credentials when not using AWS — avoids credential resolution entirely
  access_key = var.cloud_provider != "aws" ? "unused" : null
  secret_key = var.cloud_provider != "aws" ? "unused" : null

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      EnvName     = var.env_name
      EnvStage    = var.env_stage
      Project     = var.project_name
    }
  }
}

# -----------------------------------------------------------------------------
# Azure Provider — only active when cloud_provider == "azure"
#
# When cloud_provider != "azure", a dummy subscription_id is set to satisfy
# the provider schema without requiring Azure authentication.
# -----------------------------------------------------------------------------

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = var.env_stage == "prod"
    }
  }

  subscription_id            = var.cloud_provider == "azure" ? var.azure_subscription_id : "00000000-0000-0000-0000-000000000000"
  # if cloud provider not "azure" then skip provider registration
  resource_provider_registrations = var.cloud_provider != "azure" ? "none" : "legacy"
}
