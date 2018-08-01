#!/usr/bin/env bash
# This script automates the cold-start process of provisioning the Terraform state backend using terraform

DISABLE_ROLE_ARN=${DISABLE_ROLE_ARN:-0}

# Start from a clean slate
rm -rf .terraform terraform.tfstate

# Disable S3 backend
sed -Ei 's/^(\s+backend\s+)/#\1/' main.tf

# Disable Role ARN (necessary for root account on cold-start)
[ "${DISABLE_ROLE_ARN}" == "0" ] || sed -Ei 's/^(\s+role_arn\s+)/#\1/' main.tf

# Initialize terraform modules and providers
init-terraform

# Provision S3 bucket and dynamodb tables
terraform apply -auto-approve

export TF_BUCKET=$(terraform output -json | jq -r .tfstate_backend_s3_bucket_id.value)
export TF_DYNAMODB_TABLE=$(terraform output -json | jq -r .tfstate_backend_dynamodb_table_id.value)
export TF_BUCKET_REGION=${TF_VAR_region}

# Re-enable S3 backend
sed -Ei 's/^#(\s+backend\s+)/\1/' main.tf

# Reinitialize terraform to import state to remote backend
echo "yes" | init-terraform

# Re-enable Role ARN
[ "${DISABLE_ROLE_ARN}" == "0" ] || sed -Ei 's/^#(\s+role_arn\s+)/\1/' main.tf

# Describe how to use the S3/DynamoDB resources with Geodesic
echo "Add the following to the Geodesic Module's Dockerfile:"
echo "#----------------------------------------------"
echo "ENV TF_BUCKET=\"${TF_BUCKET}\""
echo "ENV TF_BUCKET_REGION=\"${TF_BUCKET_REGION}\""
echo "ENV TF_DYNAMODB_TABLE=\"${TF_DYNAMODB_TABLE}\""
echo "#----------------------------------------------"
echo "...and rebuild the module"
