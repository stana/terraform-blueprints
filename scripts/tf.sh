#!/usr/bin/env bash
# =============================================================================
# tf.sh — Terraform wrapper for multi-environment deployments
#
# Supports both AWS and Azure environments. The cloud_provider is detected from
# the env_name's terraform.tfvars and the correct backend template is activated.
#
# Usage:
#   ./scripts/tf.sh <env-name-path> <env_stage> <region> <command> [extra-args...]
#
# The env-name-path is relative to environments/ and can be at any depth:
#   ./scripts/tf.sh acme dev ap-southeast-2 plan
#   ./scripts/tf.sh customer/acme dev ap-southeast-2 plan
#   ./scripts/tf.sh customer/lumon prod uksouth apply
#   ./scripts/tf.sh customer/monolith sandbox australiaeast plan
#
# Variable override chain (last wins):
#   1. _shared/terraform.tfvars                        (global defaults)
#   2. <env_name>/terraform.tfvars                     (env_name-wide overrides)
#   3. <env_name>/<env>/terraform.tfvars               (optional env-wide overrides)
#   4. <env_name>/<env>/<region>/terraform.tfvars      (region-specific overrides)
#   5. -var "aws_region=$REGION" / "azure_location=$REGION"  (injected from dir name)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SHARED_DIR="$ROOT_DIR/environments/_shared"

# -- Colours for output -------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m' # No colour

# -- Usage --------------------------------------------------------------------
usage() {
  echo -e "${CYAN}Usage:${NC} $0 <env-name-path> <env_stage> <region> <terraform-command> [extra-args...]"
  echo ""
  echo "Arguments:"
  echo "  env-name-path Path to env_name config relative to environments/ (e.g. acme or customer/acme)"
  echo "  env_stage     Environment stage (sandbox, dev, test, prod)"
  echo "  region        Cloud region (e.g. ap-southeast-2, uksouth, australiaeast)"
  echo "  command       Any terraform command (init, plan, apply, destroy, ...)"
  echo ""
  echo "Examples:"
  echo "  $0 acme dev ap-southeast-2 plan"
  echo "  $0 customers/lumon prod uksouth apply -auto-approve"
  echo "  $0 customers/monolith sandbox australiaeast plan"
  echo ""

  # List available environments (search all directories under environments/ that contain terraform.tfvars)
  echo -e "${CYAN}Available environments:${NC}"
  while IFS= read -r -d '' tfvars_file; do
    name_dir="$(dirname "$tfvars_file")"
    name_rel="${name_dir#$ROOT_DIR/environments/}"
    name="$(basename "$name_dir")"
    # Detect cloud provider
    cloud="azure"
    detected=$(grep -oP 'cloud_provider\s*=\s*"\K[^"]+' "$tfvars_file" 2>/dev/null || echo "")
    [[ -n "$detected" ]] && cloud="$detected"
    for env_dir in "$name_dir"*/; do
      [[ -d "$env_dir" ]] || continue
      env="$(basename "$env_dir")"
      for region_dir in "$env_dir"*/; do
        [[ -d "$region_dir" ]] || continue
        region="$(basename "$region_dir")"
        echo "  $name_rel: $env / $region  ($cloud)"
      done
    done
  done < <(find "$ROOT_DIR/environments" -mindepth 2 -maxdepth 4 -name terraform.tfvars -not -path "*/_shared/*" -not -path "*/*/dev/*" -not -path "*/*/test/*" -not -path "*/*/prod/*" -not -path "*/*/sandbox/*" -print0 | sort -z)
  exit 1
}

# -- Detect cloud provider from env_name tfvars --------------------------------
detect_cloud_provider() {
  local env_name_tfvars="$1"
  local cloud="azure"
  if [[ -f "$env_name_tfvars" ]]; then
    local detected
    detected=$(grep -oP 'cloud_provider\s*=\s*"\K[^"]+' "$env_name_tfvars" 2>/dev/null || echo "")
    [[ -n "$detected" ]] && cloud="$detected"
  fi
  echo "$cloud"
}

# -- Activate the correct backend template ------------------------------------
activate_backend() {
  local cloud="$1"
  local backend_file="$SHARED_DIR/backend_active.tf"
  local template

  if [[ "$cloud" == "aws" ]]; then
    template="$SHARED_DIR/_backend_aws.tf.tpl"
  else
    template="$SHARED_DIR/_backend_azure.tf.tpl"
  fi

  if [[ ! -f "$template" ]]; then
    echo -e "${RED}Error:${NC} Backend template not found: $template"
    exit 1
  fi

  cp "$template" "$backend_file"
  echo -e "${BLUE}  Backend: ${cloud}${NC}"
}

# -- Validate arguments -------------------------------------------------------
[[ $# -lt 4 ]] && usage

ENV_NAME_PATH="$1"; shift
ENV="$1"; shift
REGION="$1"; shift
TF_COMMAND="$1"; shift

ENV_NAME="$(basename "$ENV_NAME_PATH")"
ENV_NAME_DIR="$ROOT_DIR/environments/$ENV_NAME_PATH"
ENV_DIR="$ENV_NAME_DIR/$ENV"
REGION_DIR="$ENV_DIR/$REGION"

if [[ ! -d "$ENV_NAME_DIR" ]]; then
  echo -e "${RED}Error:${NC} Environment name directory not found: $ENV_NAME_DIR"
  echo "Available environment names:"
  while IFS= read -r -d '' tfvars_file; do
    dir="$(dirname "$tfvars_file")"
    echo "  ${dir#$ROOT_DIR/environments/}"
  done < <(find "$ROOT_DIR/environments" -mindepth 2 -maxdepth 4 -name terraform.tfvars -not -path "*/_shared/*" -not -path "*/*/dev/*" -not -path "*/*/test/*" -not -path "*/*/prod/*" -not -path "*/*/sandbox/*" -print0 | sort -z)
  exit 1
fi

if [[ ! -d "$ENV_DIR" ]]; then
  echo -e "${RED}Error:${NC} Environment directory not found: $ENV_DIR"
  echo "Available environments for $ENV_NAME:"
  for d in "$ENV_NAME_DIR"/*/; do
    [[ -d "$d" ]] && echo "  $(basename "$d")"
  done
  exit 1
fi

if [[ ! -d "$REGION_DIR" ]]; then
  echo -e "${RED}Error:${NC} Region directory not found: $REGION_DIR"
  echo "Available regions for $ENV_NAME / $ENV:"
  for d in "$ENV_DIR"/*/; do
    [[ -d "$d" ]] && echo "  $(basename "$d")"
  done
  exit 1
fi

# -- Detect cloud provider ----------------------------------------------------
CLOUD_PROVIDER=$(detect_cloud_provider "$ENV_NAME_DIR/terraform.tfvars")

# -- Build -var-file chain (order matters: last wins) -------------------------
VAR_FILES=()
[[ -f "$SHARED_DIR/terraform.tfvars" ]]    && VAR_FILES+=(-var-file="$SHARED_DIR/terraform.tfvars")
[[ -f "$ENV_NAME_DIR/terraform.tfvars" ]]  && VAR_FILES+=(-var-file="$ENV_NAME_DIR/terraform.tfvars")
[[ -f "$ENV_DIR/terraform.tfvars" ]]       && VAR_FILES+=(-var-file="$ENV_DIR/terraform.tfvars")
[[ -f "$REGION_DIR/terraform.tfvars" ]]    && VAR_FILES+=(-var-file="$REGION_DIR/terraform.tfvars")

# -- Inject region from directory name (single source of truth) ----------------
REGION_VARS=(-var "aws_region=$REGION" -var "azure_location=$REGION")

# -- Header -------------------------------------------------------------------
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}  terraform-blueprints: ${CYAN}$ENV_NAME${NC} / ${YELLOW}$ENV${NC} / ${BLUE}$REGION${NC}  (${BLUE}$CLOUD_PROVIDER${NC})"
echo -e "${GREEN}║${NC}  Command:      ${CYAN}terraform $TF_COMMAND${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# -- Activate correct backend -------------------------------------------------
activate_backend "$CLOUD_PROVIDER"

# -- Terraform init -----------------------------------------------------------
if [[ "$TF_COMMAND" == "init" ]]; then
  echo -e "${YELLOW}==> Initializing Terraform${NC}"

  BACKEND_ARGS=()
  [[ -f "$REGION_DIR/backend.hcl" ]] && BACKEND_ARGS+=(-backend-config="$REGION_DIR/backend.hcl")

  terraform -chdir="$SHARED_DIR" init \
    "${BACKEND_ARGS[@]}" \
    -reconfigure \
    "$@"
  exit $?
fi

# For all other commands, auto-init if needed
if [[ ! -d "$SHARED_DIR/.terraform" ]]; then
  echo -e "${YELLOW}==> Running terraform init (first run)${NC}"

  BACKEND_ARGS=()
  [[ -f "$REGION_DIR/backend.hcl" ]] && BACKEND_ARGS+=(-backend-config="$REGION_DIR/backend.hcl")

  terraform -chdir="$SHARED_DIR" init \
    "${BACKEND_ARGS[@]}" \
    -reconfigure
fi

# -- Run Terraform command ----------------------------------------------------
echo -e "${YELLOW}==> terraform $TF_COMMAND${NC}"
terraform -chdir="$SHARED_DIR" "$TF_COMMAND" \
  "${VAR_FILES[@]}" \
  "${REGION_VARS[@]}" \
  "$@"
