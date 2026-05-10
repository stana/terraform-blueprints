# Architecture Overview

## System Design

terraform-blueprints is a multi-cloud, multi-environment Terraform framework built on a layered abstraction model. It uses a single shared codebase to deploy infrastructure across AWS and Azure, with environment-aware defaults that scale from sandbox to production.

### Core Principle

**No Terraform code duplication.** All `.tf` files live in `environments/_shared/`. Environments consist only of `.tfvars` overrides and `backend.hcl` state configurations.

---

## Layered Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                     Environment Configs                          │
│  terraform.tfvars + backend.hcl per env_name/env_stage/region    │
│  (what to deploy, where, and how big)                            │
└────────────────────────────┬─────────────────────────────────────┘
                             │ -var-file chain (last wins)
                             ▼
┌──────────────────────────────────────────────────────────────────┐
│                   Shared Orchestrator                             │
│  environments/_shared/main.tf                                    │
│  Selects blueprints based on var.blueprints                      │
│  Passes variables, injects name_prefix, gates with count         │
└────────────────────────────┬─────────────────────────────────────┘
                             │ module calls (count-gated)
                             ▼
┌──────────────────────────────────────────────────────────────────┐
│                       Blueprints                                 │
│  Opinionated compositions with environment-aware defaults        │
│  local.env_config maps (sandbox/dev/test/prod)                   │
│  Cloud-agnostic interface, cloud-specific internals              │
└────────────────────────────┬─────────────────────────────────────┘
                             │ module calls (cloud-gated)
                             ▼
┌──────────────────────────────────────────────────────────────────┐
│                        Modules                                   │
│  Single-concern, cloud-specific building blocks                  │
│  No environment logic — pure resource provisioning               │
└──────────────────────────────────────────────────────────────────┘
```

---

## Main Components

### 1. Shared Orchestrator (`environments/_shared/`)

The single source of truth for all Terraform configuration.

| File | Purpose |
|------|---------|
| `main.tf` | Entry point. Instantiates blueprint modules gated by `contains(var.blueprints, "<name>")`. Generates `name_prefix` as `{env_name}-{env_stage}`. |
| `variables.tf` | ~850 lines. All variable declarations with validation rules (`env_stage`, `cloud_provider`, `blueprints`). Organized by concern: general, AWS, Azure, feature flags, blueprint-specific. |
| `outputs.tf` | Cloud-agnostic outputs routed from blueprints via ternary logic. Includes `environment_info` metadata. |
| `providers.tf` | Multi-cloud provider isolation. Unused provider gets dummy credentials and skip flags to prevent authentication errors. Default tags applied at provider level. |
| `versions.tf` | Terraform >= 1.5.0, AWS ~> 5.0, Azure ~> 4.0, TLS ~> 4.0, Random ~> 3.0. |
| `terraform.tfvars` | Global defaults (lowest precedence): `project_name`, default `aws_region`. |
| `backend_active.tf` | Active backend block. Replaced by `tf.sh` from `_backend_aws.tf.tpl` or `_backend_azure.tf.tpl` before init. |

### 2. Wrapper Script (`scripts/tf.sh`)

Orchestrates Terraform execution with environment-aware context.

```
Usage: ./scripts/tf.sh <env-name-path> <env_stage> <region> <command> [extra-args]
```

**Responsibilities:**
- Auto-detects `cloud_provider` from environment tfvars
- Copies the correct backend template before `init`
- Builds the variable file override chain (last wins):
  `_shared/terraform.tfvars` → `<env>/terraform.tfvars` → `<env>/<stage>/terraform.tfvars` (optional) → `<env>/<stage>/<region>/terraform.tfvars`
- Injects `-var aws_region=<REGION>` and `-var azure_location=<REGION>` from the directory name
- Auto-runs `init` if `.terraform/` directory is missing
- Passes `-backend-config=backend.hcl` for state isolation

### 3. Blueprints (`blueprints/`)

Higher-level, opinionated application deployments that compose modules. Each blueprint:
- Defines a `local.env_config` map with sandbox/dev/test/prod tiers
- Conditionally creates AWS or Azure resources based on `cloud_provider`
- Exposes a simplified variable interface
- Produces cloud-agnostic outputs

#### Available Blueprints

| Blueprint | Path | Cloud | Composes | Use Case |
|-----------|------|-------|----------|----------|
| `web-app` | `blueprints/services/web-app/` | AWS + Azure | networking → compute → database | Multi-tier web applications |
| `api-app` | `blueprints/services/api-app/` | Azure | networking → container-app → storage | Managed container workloads |
| `appliance` | `blueprints/services/appliance/` | Azure | networking (opt) → compute → keyvault (opt) | VM-based appliances |
| `hub-network` | `blueprints/network/hub/` | Azure | networking → firewall → bastion | Hub-spoke network topology |
| `data-pipeline` | `blueprints/data/pipeline/` | AWS + Azure | networking → compute (workers) → storage | ETL / batch processing |

#### Environment-Aware Defaults (Example: web-app)

| Setting | sandbox/dev | test | prod |
|---------|-------------|------|------|
| NAT Gateway | Disabled | Single | HA (per-AZ) |
| Database Multi-AZ | No | No | Yes |
| Deletion Protection | No | No | Yes |
| Backup Retention | 1 day | 3 days | 30 days |

### 4. Modules (`modules/`)

Low-level, single-concern, cloud-specific building blocks. They contain no environment logic — that belongs in blueprints.

#### AWS Modules

| Module | Resources | Key Behaviour |
|--------|-----------|---------------|
| `aws-networking` | VPC, IGW, subnets, route tables, NAT gateways, EIPs | Single vs. HA NAT gateways. Public subnets auto-assign public IPs. |
| `aws-compute` | EC2 instances, security groups, AMI lookup | Amazon Linux 2023 default. gp3 encrypted volumes. IMDSv2 required. Instances spread across subnets via modulo. |
| `aws-database` | RDS, DB subnet group, security groups | Engine-aware port selection. AWS Secrets Manager for passwords. Ingress restricted to 10.0.0.0/8. |

#### Azure Modules

| Module | Resources | Key Behaviour |
|--------|-----------|---------------|
| `azure-networking` | Resource group, VNet, subnets, NSG, private DNS zone | Auto-delegates last subnet for PostgreSQL when 2+ subnets provided. Creates private DNS zone for database connectivity. |
| `azure-compute` | Linux VMs, NICs, TLS SSH keys | Ubuntu 24.04 LTS. Premium SSD. Private IP only. RSA 4096-bit SSH key generated. |
| `azure-database` | PostgreSQL Flexible Server, database, random password | Zone-redundant HA in prod. Delegated subnet + private DNS zone integration. 24-char random password. |
| `azure-container-app` | Container App Environment, Container App, Log Analytics | Auto-creates Log Analytics if not provided. Dynamic env vars. Configurable revision mode and scaling. |
| `azure-keyvault` | Key Vault | RBAC authorization. Configurable soft-delete retention and purge protection. |

### 5. Environment Configurations (`environments/`)

Each environment is an organisational grouping of tfvars and backend configs.

```
environments/
├── _shared/                          # Terraform code (single source of truth)
├── customer/
│   ├── acme/                         # AWS — web-app
│   │   ├── terraform.tfvars          # cloud_provider="aws", blueprints=["web-app"]
│   │   ├── dev/ap-southeast-2/       # Dev in Sydney
│   │   ├── test/ap-southeast-2/      # Test in Sydney
│   │   └── prod/ap-southeast-2/     # Prod in Sydney
│   └── lumon/                        # Azure — web-app
│       ├── terraform.tfvars          # cloud_provider="azure", blueprints=["web-app"]
│       ├── dev/uksouth/              # Dev in UK South
│       ├── test/uksouth/             # Test in UK South
│       └── prod/uksouth/            # Prod in UK South
└── testhub/                          # Azure — hub-network
    ├── terraform.tfvars              # blueprints=["hub-network"]
    ├── dev/australiaeast/            # Dev hub in Australia East
    └── prod/australiaeast/          # Prod hub in Australia East
```

---

## Data Flow

### Variable Resolution

Variables are resolved through a last-wins override chain, assembled by `tf.sh`:

```
 1. _shared/terraform.tfvars          ← global defaults (project_name, aws_region)
 2. <env>/terraform.tfvars            ← env-level (cloud_provider, blueprints, env_name)
 3. <env>/<stage>/terraform.tfvars    ← stage-level overrides (optional, not always present)
 4. <env>/<stage>/<region>/tfvars     ← region-level (env_stage, CIDRs, instance sizes)
 5. -var aws_region=<REGION>          ← injected from directory name (final override)
    -var azure_location=<REGION>
```

### Deployment Flow

```
  tf.sh invoked
    │
    ├─ Reads cloud_provider from env tfvars
    ├─ Copies correct backend template → backend_active.tf
    ├─ Builds -var-file chain
    ├─ Injects region vars from directory name
    │
    ▼
  terraform <command>
    │
    ├─ _shared/main.tf evaluates var.blueprints
    ├─ Instantiates matching blueprint modules (count-gated)
    │
    ▼
  Blueprint (e.g. web-app)
    │
    ├─ Reads env_stage → selects env_config tier
    ├─ Merges environment defaults with user overrides
    ├─ Checks cloud_provider → gates AWS vs Azure modules
    │
    ▼
  Modules (e.g. aws-networking, aws-compute, aws-database)
    │
    └─ Provisions cloud resources
```

### State Isolation

Each `env_name/env_stage/region` combination stores state independently:

- **AWS (S3):** `bucket=<env>-terraform-state`, `key=<stage>/<region>/terraform.tfstate`, DynamoDB locking
- **Azure (Storage):** `storage_account_name=<env>terraform`, `key=<stage>/<region>/terraform.tfstate`

Backend configuration is provided at init time via `-backend-config=backend.hcl`.

---

## Key Design Patterns

### Multi-Cloud Provider Isolation

The unused cloud provider is neutralized at the provider level to prevent authentication failures:

- **AWS inactive:** `skip_credentials_validation = true`, `skip_requesting_account_id = true`, `access_key = "unused"`
- **Azure inactive:** `subscription_id = "00000000-..."`, `resource_provider_registrations = "none"`

### Feature Flags

Boolean variables gate optional components throughout the stack:

| Flag | Controls | Gate Pattern |
|------|----------|-------------|
| `enable_database` | RDS / PostgreSQL | `count = var.enable_database ? 1 : 0` |
| `enable_waf` | Web Application Firewall | Blueprint-level |
| `enable_cdn` | Content Delivery Network | Blueprint-level |
| `enable_storage` | Storage accounts / S3 | Blueprint-level |
| `enable_keyvault` | Azure Key Vault | Blueprint-level |
| `enable_firewall` | Azure Firewall | Hub blueprint |
| `enable_networking` | VNet creation | Appliance (use external subnet instead) |

### Cloud-Agnostic Outputs

Blueprints map cloud-specific resources to generic output names:

```
network_id         → AWS VPC ID    / Azure VNet ID
subnet_ids         → AWS subnets   / Azure subnets
compute_instance_ids → EC2 IDs     / VM IDs
database_endpoint  → RDS endpoint  / PostgreSQL FQDN
```

### Tagging Strategy

Tags are applied at multiple levels and merged:

1. **Provider defaults:** `ManagedBy`, `EnvName`, `EnvStage`, `Project` (AWS provider block)
2. **Module-level:** Applied via `tags = merge(...)` in Azure modules
3. **Blueprint-level:** `Blueprint = "<name>"` added to child resources
4. **User-level:** `extra_tags` variable merged into all resources (e.g., `CostCentre`)

### Production Hardening

The `prod` env_stage tier automatically applies:

- Multi-AZ / zone-redundant deployments
- HA NAT gateways (one per AZ)
- Deletion protection on databases
- Extended backup retention (30-35 days)
- Geo-redundant storage replication (GRS)
- Purge protection on Key Vaults (90-day soft delete)
- Premium Firewall and Standard Bastion SKUs
- Multiple revision mode for container apps
- `prevent_deletion_if_contains_resources = true` on Azure resource groups

---

## File Statistics

| Component | Files | Purpose |
|-----------|-------|---------|
| Shared orchestrator | 10 | Terraform code (all `.tf` files) |
| Blueprints | 15 | Composition layer (5 blueprints × 3 files) |
| Modules | 24 | Cloud primitives (8 modules × 3 files) |
| Environment configs | 27 | tfvars + backend.hcl |
| Scripts | 1 | Wrapper script |
| **Total** | **~77** | |
