#!/usr/bin/env bash
# This script destroys the tfstate backend

# We use this variable consistently to pass the role we wish to assume in our root modules
export TF_VAR_aws_assume_role_arn="${TF_VAR_aws_assume_role_arn:-false}"

DISABLE_ROLE_ARN=${DISABLE_ROLE_ARN:-false}

# Start with a clean slate
rm -rf .terraform terraform.tfstate

# Disable Role ARN (necessary for root account when using master credentials)
[ "${DISABLE_ROLE_ARN}" == "true" ] || sed -Ei 's/^(\s+role_arn\s+)/#\1/' main.tf

# Init terraform with S3 state enabled. Assumes state was previously initialized.
terraform init

# Unmount remote bucket (if mounted)
s3 unmount

# Store the current state so we can destroy resources without catch-22
terraform state pull > terraform.tfstate

# Delete current state folder to remove all hints of local & remote state
rm -rf .terraform

# Disable S3 state backend so that we use local state file
sed -Ei 's/^(\s+backend\s+)/#\1/' main.tf

# Reinitialize TF state without backend, using local `terraform.tfstate`
terraform init

# Destroy terraform state. Note, only buckets that were created with `force_destroy=true` will successfully be destroyed.
#   https://github.com/hashicorp/terraform/issues/7854#issuecomment-293893541
terraform destroy -auto-approve

# Re-enable S3 backend
sed -Ei 's/^#(\s+backend\s+)/\1/' main.tf

# Re-enable Role ARN
[ "${DISABLE_ROLE_ARN}" == "true" ] || sed -Ei 's/^#(\s+role_arn\s+)/\1/' main.tf

# Clean up
rm -rf .terraform terraform.tfstate
