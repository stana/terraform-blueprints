# =============================================================================
# Acme — AWS environment 
# Overrides global defaults from _shared/terraform.tfvars.
# Per-environment tfvars override these values in turn.
# =============================================================================

env_name          = "acme"
cloud_provider    = "aws"
enable_monitoring = true
blueprints        = ["web-app"]

extra_tags = {
  CostCentre = "acme-ops"
}
