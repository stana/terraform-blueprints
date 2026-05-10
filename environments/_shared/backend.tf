# Partial backend configuration.
# Completed per-environment via -backend-config=<env>/backend.hcl
#
# IMPORTANT: Terraform only allows ONE backend block. The wrapper script (tf.sh)
# determines which backend to use based on the customer's cloud_provider setting.
# See the _backend_*.tf files for the actual backend blocks.
#
# For AWS customers:  backend "s3" {}      + backend.hcl with bucket/key/region
# For Azure customers: backend "azurerm" {} + backend.hcl with storage_account/container/key
#
# Since Terraform requires exactly one backend block at init time, the wrapper
# script symlinks the correct backend file before running init.
