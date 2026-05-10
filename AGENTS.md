# terraform-blueprints - Terraform Blueprints - Multi-Environment, Multi-Cloud Terraform Framework

## Project Structure

```
terraform-blueprints/
├── blueprints/                       # Higher-level application deployments
│   ├── services/                     # Service-oriented blueprints
│   │   ├── web-app/                  # Web application (networking + compute + DB + CDN/WAF)
│   │   ├── api-app/                  # Azure Container App (networking + container app + storage)
│   │   └── appliance/                # Azure VM (networking + compute + Key Vault)
│   ├── network/                      # Network-oriented blueprints
│   │   └── hub/                      # Hub network (VNet + Firewall + Bastion)
│   └── data/                         # Data-oriented blueprints
│       └── pipeline/                 # Data processing (networking + workers + storage)
├── modules/                          # Low-level, single-concern modules
│   ├── aws-networking/               # AWS: VPC, subnets, NAT, routing
│   ├── aws-compute/                  # AWS: EC2 instances, security groups
│   ├── aws-database/                 # AWS: RDS, subnet groups
│   ├── azure-networking/             # Azure: VNet, subnets, NSG, resource group
│   ├── azure-compute/                # Azure: Linux VMs, NICs
│   ├── azure-database/               # Azure: PostgreSQL Flexible Server
│   ├── azure-container-app/          # Azure: Container App + Environment + Log Analytics
│   └── azure-keyvault/               # Azure: Key Vault with RBAC
├── scripts/
│   └── tf.sh                         # Wrapper script (handles AWS + Azure)
├── environments/
│   ├── _shared/                      # Shared .tf files (single source of truth)
│   │   ├── main.tf                   # Blueprint orchestration (calls blueprints based on var.blueprints)
│   │   ├── variables.tf              # All variable declarations
│   │   ├── outputs.tf                # All outputs (routed through blueprints)
│   │   ├── providers.tf              # Provider configuration (AWS + Azure)
│   │   ├── backend.tf                # Documentation for backend strategy
│   │   ├── _backend_aws.tf.tpl       # Backend template for AWS (S3)
│   │   ├── _backend_azure.tf.tpl     # Backend template for Azure (azurerm)
│   │   ├── versions.tf               # Required versions
│   │   └── terraform.tfvars          # Global defaults
│   └── ...
└── .gitignore
```

## Architecture: Blueprints → Modules

```
tfvars (what to deploy)
  → _shared/main.tf (orchestrator)
    → blueprints/ (higher-level compositions)
      → modules/ (low-level cloud resources)
```

**Modules** are low-level, single-concern, cloud-specific building blocks (e.g. "create a VPC", "create an RDS instance").

**Blueprints** are repeatable, opinionated application deployments that compose multiple modules. A blueprint:
- Has a simplified variable interface (high-level knobs, not infrastructure details)
- Encodes environment-aware defaults (prod gets multi-AZ, HA NAT, deletion protection, etc.)
- Handles all internal wiring between modules
- Provides cloud-agnostic outputs

### Available Blueprints

| Blueprint | Directory | Composes | Purpose |
|---|---|---|---|
| `web-app` | `blueprints/services/web-app/` | networking + compute + database + (CDN, WAF) | Traditional web applications |
| `api-app` | `blueprints/services/api-app/` | azure-networking + azure-container-app + (storage) | Azure Container Apps |
| `appliance` | `blueprints/services/appliance/` | azure-networking + azure-compute + (azure-keyvault) | Azure VMs with optional Key Vault |
| `hub-network` | `blueprints/network/hub/` | azure-networking + Azure Firewall + Azure Bastion | Hub network for hub-spoke topology |
| `data-pipeline` | `blueprints/data/pipeline/` | networking + workers + object storage | ETL, batch processing, data lake |

### Selecting Blueprints

Set in env_name tfvars:
```hcl
blueprints = ["web-app"]                       # Single blueprint
blueprints = ["api-app", "appliance"]          # Multiple blueprints
blueprints = ["hub-network"]                   # Hub network for hub-spoke
```

## Key Conventions

- **No .tf duplication**: All Terraform code lives in `environments/_shared/`. Environments only have `.tfvars` and `backend.hcl`.
- **Multi-cloud via `cloud_provider`**: Set `cloud_provider = "aws"` or `cloud_provider = "azure"` in the env_name tfvars. Default is `"azure"`.
- **Provider isolation**: The unused cloud provider receives dummy credentials and skip flags so Terraform never attempts real authentication against it.
- **Blueprint-driven**: `main.tf` calls blueprints, not raw modules. Blueprints handle environment-aware defaults internally.
- **Config path**: Environment configs live under `environments/<env_name_path>/` (e.g. `environments/acme/` or `environments/customer/acme/`).
- **Multi-region**: Region is a required argument and is the single source of truth for `aws_region`/`azure_location`. The script injects `-var "aws_region=$REGION"` and `-var "azure_location=$REGION"` automatically — do not set these in tfvars.
- **Variable override chain** (via `-var-file` and `-var`, last wins):
  `_shared/terraform.tfvars` → `<env_name_path>/terraform.tfvars` → `<env_name_path>/<env_stage>/terraform.tfvars` (optional) → `<env_name_path>/<env_stage>/<region>/terraform.tfvars` → `-var aws_region/azure_location` (injected from directory name)
- **Valid env_stage values**: `sandbox`, `dev`, `test`, `prod`.
- **State isolation**: Each env_name/env_stage/region combination has its own backend config.
- **Feature flags**: Boolean variables (`enable_database`, `enable_storage`, `enable_keyvault`, `enable_waf`, etc.) with `count` conditionals.
- **Backend switching**: `tf.sh` copies the correct backend template based on `cloud_provider`.

## Running Terraform

Always use the wrapper script. Region is always required:

```bash
./scripts/tf.sh <env-name-path> <env_stage> <region> <command> [extra-args]

# Examples:
./scripts/tf.sh customer/acme dev ap-southeast-2 init
./scripts/tf.sh customer/acme dev ap-southeast-2 plan
```

## Adding a New Environment

1. Create `environments/<env_name_path>/terraform.tfvars` with env_name-wide settings:
   - Set `cloud_provider` (`"aws"` or `"azure"`)
   - Set `blueprints` (e.g. `["web-app"]`, `["api-app", "appliance"]`)
   - Do NOT set `aws_region` or `azure_location` — these are injected from the region directory name
2. Create env_stage and region directories (e.g. `dev/<region>/`, `prod/<region>/`)
3. Add `terraform.tfvars` and `backend.hcl` to each region directory
4. State key in `backend.hcl` must include region: `key = "<env>/<region>/terraform.tfstate"`
5. For AWS: ensure S3 bucket and DynamoDB table exist for the backend
6. For Azure: ensure Storage Account and container exist for the backend

## Adding a New Blueprint

1. Create `blueprints/<category>/<name>/` with `main.tf`, `variables.tf`, `outputs.tf`
   - Use `blueprints/services/` for service-oriented blueprints
   - Use `blueprints/network/` for network-oriented blueprints
   - Use `blueprints/data/` for data-oriented blueprints
2. In the blueprint, compose modules from `modules/` using relative paths
3. Add environment-aware defaults in a `local.env_config` map (must include keys: `sandbox`, `dev`, `test`, `prod`)
4. Add the blueprint to the validation list in `_shared/variables.tf` (`var.blueprints`)
5. Add a `module "<name>"` block in `_shared/main.tf` gated by `contains(var.blueprints, "<name>")`
6. Wire outputs through `_shared/outputs.tf`

## Adding a New Module

1. Create `modules/<name>/` with `main.tf`, `variables.tf`, `outputs.tf`
2. Reference it from the relevant blueprint(s) using relative paths
3. The module should NOT contain environment-aware logic — that belongs in the blueprint

## Cloud Provider Details

### AWS Environments
- Backend: S3 + DynamoDB locking
- `backend.hcl` keys: `bucket`, `key`, `region`, `dynamodb_table`, `encrypt`
- State key pattern: `<env>/<region>/terraform.tfstate`

### Azure Environments
- Backend: Azure Storage Account
- `backend.hcl` keys: `resource_group_name`, `storage_account_name`, `container_name`, `key`
- State key pattern: `<env>/<region>/terraform.tfstate`
- `azure_subscription_id` must be set via `TF_VAR_azure_subscription_id` env var or CI/CD secret
