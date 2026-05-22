# terraform-blueprints (Terraform Blueprints)

A multi-environment, multi-cloud Terraform framework that deploys cloud infrastracture (AWS, Azure) defined as modules and blueprints. Blueprints are repeatable deployment definitions composed of multiple modules allowing repeatable deployment of a colleciton of cloud resources.

## Overview

terraform-blueprints separates **what to deploy** (env_name/environment tfvars) from **how to deploy it** (blueprints and modules). Users select pre-built blueprints, set a few variables, and the framework handles networking, compute, databases, and cloud-specific wiring automatically — with dev, test, prod environment-aware defaults.

## Acknowledgements

Build with the assistance of AI.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) (for AWS environments)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) (for Azure environments)
- Bash shell (the wrapper script requires it)

## Architecture

```
Env name tfvars (what to deploy)
  → environments/_shared/main.tf (orchestrator)
    → blueprints/ (opinionated compositions)
      → modules/ (single-concern cloud resources)
```

**Modules** are low-level building blocks — a single VPC, a single RDS instance, a single Key Vault. They have no opinion about environments.

**Blueprints** compose multiple modules into a complete deployment. They encode environment-aware defaults (prod gets HA, deletion protection, longer backups) so users don't need to think about infrastructure details.

### Available Blueprints

| Blueprint | Directory | Cloud | What it creates |
|---|---|---|---|
| `web-app` | `blueprints/services/web-app/` | AWS + Azure | Networking + compute + database + optional CDN/WAF |
| `api-app` | `blueprints/services/api-app/` | Azure | Networking + Container App + optional storage |
| `appliance` | `blueprints/services/appliance/` | Azure | Networking + VMs + optional Key Vault |
| `hub-network` | `blueprints/network/hub/` | Azure | Hub VNet + Azure Firewall + optional Bastion |
| `data-pipeline` | `blueprints/data/pipeline/` | AWS + Azure | Networking + worker instances + object storage |

## Quick Start

### 1. Authenticate

**AWS:**
```bash
aws configure
# or
export AWS_PROFILE=your-profile
```

**Azure:**
```bash
az login
az account set --subscription "<subscription-id>"
export TF_VAR_azure_subscription_id="<subscription-id>"
```

### 2. Create Backend Storage

State files are stored remotely. The backend resources must exist before running `terraform init`.

**AWS** (S3 + DynamoDB):
```bash
aws s3 mb s3://<env_name>-terraform-state --region <region>
aws dynamodb create-table \
  --table-name <env_name>-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region <region>
```

**Azure** (Storage Account):
```bash
az group create --name <env_name>-tfstate-rg --location <region>
az storage account create \
  --name <env_name>terraform \
  --resource-group <env_name>-tfstate-rg \
  --location <region> \
  --sku Standard_LRS
az storage container create \
  --name tfstate \
  --account-name <env_name>terraform
```

### 3. Initialise and Plan

```bash
./scripts/tf.sh example/customer/lumon dev australiaeast init
./scripts/tf.sh example/customer/lumon dev australiaeast plan
```

### 4. Apply

```bash
./scripts/tf.sh example/customer/acme dev ap-southeast-2 apply
```

## Usage

```bash
./scripts/tf.sh <env-name-path> <env_stage> <region> <command> [extra-args]
```

| Argument | Description |
|---|---|
| `env-name-path` | Path to env_name config relative to `environments/` (e.g. `acme` or `customer/acme`) |
| `env_stage` | `sandbox`, `dev`, `test`, or `prod` |
| `region` | Cloud region (e.g. `ap-southeast-2`, `uksouth`, `australiaeast`) |
| `command` | Any Terraform command: `init`, `plan`, `apply`, `destroy`, etc. |

**Examples:**
```bash
./scripts/tf.sh example/customer/acme dev ap-southeast-2 plan
./scripts/tf.sh example/customer/acme prod ap-southeast-2 apply
./scripts/tf.sh example/customer/lumon test uksouth plan
./scripts/tf.sh example/customer/acme prod ap-southeast-2 apply -auto-approve
```

The wrapper script handles:
- Detecting the cloud provider from the env_name's tfvars
- Activating the correct backend template (S3 or azurerm)
- Loading the tfvars chain in the right order (global → env_name → env → region)
- Auto-initialising on first run

## Project Structure

```
terraform-blueprints/
├── blueprints/
│   ├── services/
│   │   ├── web-app/              # Networking + compute + DB
│   │   ├── api-app/              # Container App + networking + storage
│   │   └── appliance/            # VMs + networking + Key Vault
│   ├── network/
│   │   └── hub/                  # Hub VNet + Firewall + Bastion
│   └── data/
│       └── pipeline/             # Workers + networking + object storage
├── modules/
│   ├── aws-networking/           # AWS VPC, subnets, NAT
│   ├── aws-compute/              # AWS EC2 instances
│   ├── aws-database/             # AWS RDS
│   ├── azure-networking/         # Azure VNet, subnets, NSG
│   ├── azure-compute/            # Azure Linux VMs
│   ├── azure-database/           # Azure PostgreSQL Flexible Server
│   ├── azure-container-app/      # Azure Container App + Environment
│   └── azure-keyvault/           # Azure Key Vault
├── scripts/
│   └── tf.sh                     # Wrapper script
├── environments/
│   ├── _shared/                  # All .tf code (single source of truth)
│   └── ...
└── scripts/
    └── tf.sh                     # Wrapper script
```

## Environment Configuration

Environments are configured entirely through `.tfvars` files — no `.tf` code is duplicated. The variable override chain (last wins):

1. `environments/_shared/terraform.tfvars` — global defaults
2. `environments/<env_name_path>/terraform.tfvars` — env_name-wide settings
3. `environments/<env_name_path>/<env_stage>/terraform.tfvars` — optional env-wide overrides
4. `environments/<env_name_path>/<env_stage>/<region>/terraform.tfvars` — region-specific overrides
5. `-var "aws_region=$REGION"` / `-var "azure_location=$REGION"` — injected automatically from the region directory name

The region is never set in tfvars — it's derived from the directory structure by `tf.sh`.

## Adding a New Environment

1. Create `environments/<env_name_path>/terraform.tfvars`:
   ```hcl
   cloud_provider = "azure"    # default; set to "aws" for AWS environments
   env_name       = "<env_name>"
   blueprints     = ["web-app"]
   ```
   Do not set `aws_region` or `azure_location` — these are injected from the region directory name.

2. Create env_stage and region directories with `terraform.tfvars` and `backend.hcl`:
   ```
   environments/<env_name_path>/
   ├── terraform.tfvars
   ├── dev/
   │   └── australiaeast/
   │       ├── terraform.tfvars    # env_stage = "dev", networking CIDRs, instance sizes
   │       └── backend.hcl         # state key: "dev/australiaeast/terraform.tfstate"
   └── prod/
       └── australiaeast/
           ├── terraform.tfvars
           └── backend.hcl
   ```

3. Create the backend storage resources (see [Quick Start](#2-create-backend-storage)).

4. Initialise and plan:
   ```bash
   ./scripts/tf.sh <env_name_path> dev australiaeast init
   ./scripts/tf.sh <env_name_path> dev australiaeast plan
   ```

### Multi-Region Deployment

To deploy the same env_name/environment to multiple regions, add region directories:

```
environments/<env_name_path>/
├── terraform.tfvars
└── prod/
    ├── australiaeast/
    │   ├── terraform.tfvars     # CIDRs, instance sizes (region injected by tf.sh)
    │   └── backend.hcl          # key = "prod/australiaeast/terraform.tfstate"
    └── uksouth/
        ├── terraform.tfvars     # CIDRs, instance sizes (region injected by tf.sh)
        └── backend.hcl          # key = "prod/uksouth/terraform.tfstate"
```

Each region has its own state file, so deployments are fully independent.

## Environment-Aware Defaults

Blueprints automatically adjust settings based on the env_stage. You don't need to configure these — just set `env_stage = "prod"` and the blueprint handles the rest.

**web-app example:**

| Setting | sandbox/dev | test | prod |
|---|---|---|---|
| NAT Gateway | Disabled | Single | Per-AZ (HA) |
| DB Multi-AZ | No | No | Yes |
| Deletion Protection | No | No | Yes |
| Backup Retention | 1 day | 3 days | 30 days |

**appliance example:**

| Setting | sandbox/dev | test | prod |
|---|---|---|---|
| KV Purge Protection | No | No | Yes |
| KV Soft Delete | 7 days | 7 days | 90 days |

## Sensitive Variables

The `azure_subscription_id` is intentionally left empty in tfvars. Set it via environment variable:

```bash
export TF_VAR_azure_subscription_id="00000000-1234-5678-abcd-000000000000"
```

For CI/CD, inject it as a secret.

## Feature Flags

Blueprints support optional components controlled by boolean variables:

| Variable | Blueprint | What it enables |
|---|---|---|
| `enable_database` | web-app | Managed database (RDS / PostgreSQL Flexible Server) |
| `container_app_enable_storage` | api-app | Azure Storage Account for persistence |
| `vm_enable_keyvault` | appliance | Azure Key Vault alongside VMs |
| `hub_enable_firewall` | hub-network | Azure Firewall in the hub (on by default) |
| `enable_waf` | web-app | Web Application Firewall |
| `enable_cdn` | web-app | CDN (CloudFront / Azure CDN) |
