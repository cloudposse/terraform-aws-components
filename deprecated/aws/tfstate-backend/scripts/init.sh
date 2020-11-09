#!/usr/bin/env bash
# This script automates the cold-start process of provisioning the Terraform state backend using terraform

set -e

# We use this variable consistently to pass the role we wish to assume in our root modules
export TF_VAR_aws_assume_role_arn="${TF_VAR_aws_assume_role_arn:-false}"

DISABLE_ROLE_ARN=${DISABLE_ROLE_ARN:-false}

# Start from a clean slate
rm -rf .terraform terraform.tfstate

# Disable S3 backend. We'll import state afterwards.
sed -Ei 's/^(\s+backend\s+)/#\1/' main.tf

# Disable Role ARN (necessary for root account on cold-start)
[ "${DISABLE_ROLE_ARN}" == "true" ] || sed -Ei 's/^(\s+role_arn\s+)/#\1/' main.tf

# Initialize terraform modules and providers
terraform init -from-module=

# Provision S3 bucket and dynamodb tables
terraform apply -auto-approve -input=false

export TF_BUCKET=$(terraform output tfstate_backend_s3_bucket_id)
export TF_DYNAMODB_TABLE=$(terraform output tfstate_backend_dynamodb_table_id)

# Cast to terraform envs
eval "$(tfenv)"

# Re-enable S3 backend
sed -Ei 's/^#(\s+backend\s+)/\1/' main.tf

# Reinitialize terraform to import state to remote backend
terraform init -from-module= -force-copy

# Re-enable Role ARN
[ "${DISABLE_ROLE_ARN}" == "true" ] || sed -Ei 's/^#(\s+role_arn\s+)/\1/' main.tf

# Describe how to use the S3/DynamoDB resources with Geodesic
echo "Add the following to the Geodesic Module's Dockerfile:"
echo "#----------------------------------------------"
echo "ENV TF_BUCKET=\"${TF_BUCKET}\""
echo "ENV TF_BUCKET_REGION=\"${TF_BUCKET_REGION}\""
echo "ENV TF_DYNAMODB_TABLE=\"${TF_DYNAMODB_TABLE}\""
echo "#----------------------------------------------"
echo "...and rebuild the module"
