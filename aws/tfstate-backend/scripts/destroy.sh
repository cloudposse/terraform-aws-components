# Start with a clean slate
rm -rf .terraform terraform.tfstate

# Init terraform with S3 state enabled. Assumes state was previously initialized.
init-terraform

# Unmount remote bucket
s3 unmount

# Store the current state
terraform state pull > terraform.tfstate

# Delete current state folder
rm -rf .terraform

# Disable S3 state backend
sed -Ei 's/^(\s+backend\s+)/#\1/' main.tf

# Reintialize TF state without backend
terraform init

# Destroy terraform state. Note, only buckets that were created with `force_destroy=true` will successfully be destroyed.
#   https://github.com/hashicorp/terraform/issues/7854#issuecomment-293893541
terraform destroy -auto-approve

# Re-enable S3 backend
sed -Ei 's/^#(\s+backend\s+)/\1/' main.tf

# Clean up
rm -rf .terraform terraform.tfstate
