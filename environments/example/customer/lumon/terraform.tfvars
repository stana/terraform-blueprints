# =============================================================================
# Lumon — Azure environment
# Demonstrates using a different cloud provider within the same framework.
# =============================================================================

env_name              = "lumon"
cloud_provider        = "azure"
azure_subscription_id = ""  # Set via environment variable or CI/CD

enable_monitoring = true
blueprints        = ["web-app"]

extra_tags = {
  CostCentre = "lumon-ops"
}
