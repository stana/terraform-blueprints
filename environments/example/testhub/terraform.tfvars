# =============================================================================
# Test Hub — Azure environment
# Deploys a hub network (VNet + Firewall + Bastion) for hub-spoke topology.
# Spoke environments reference hub outputs via terraform_remote_state.
# =============================================================================

cloud_provider        = "azure"
env_name              = "testhub"
azure_subscription_id = ""  # Hub subscription — set via TF_VAR_azure_subscription_id

blueprints = ["hub-network"]

extra_tags = {
  CostCentre = "shared-networking"
}
