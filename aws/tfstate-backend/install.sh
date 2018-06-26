#!/usr/bin/env bash

DISABLE_ROLE_ARN=${DISABLE_ROLE_ARN:-0}

sed -Ei 's/^(\s+backend\s+)/#\1/' main.tf
[ "${DISABLE_ROLE_ARN}" == "0" ] || sed -Ei 's/^(\s+role_arn\s+)/#\1/' main.tf

init-terraform
echo "yes" | terraform apply

export TF_BUCKET=$(terraform output -json | jq -r .tfstate_backend_s3_bucket_id.value)
export TF_DYNAMODB_TABLE=$(terraform output -json | jq -r .tfstate_backend_dynamodb_table_id.value)
export TF_BUCKET_REGION=${TF_VAR_region}

sed -Ei 's/^#(\s+backend\s+)/\1/' main.tf

echo "yes" | init-terraform

[ "${DISABLE_ROLE_ARN}" == "0" ] || sed -Ei 's/^#(\s+role_arn\s+)/\1/' main.tf

echo "Add the following to the Geodesic Module's Dockerfile:"
echo "#----------------------------------------------"
echo "ENV TF_BUCKET=\"${TF_BUCKET}\""
echo "ENV TF_BUCKET_REGION=\"${TF_BUCKET_REGION}\""
echo "ENV TF_DYNAMODB_TABLE=\"${TF_DYNAMODB_TABLE}\""
echo "#----------------------------------------------"
echo "And rebuild the module"
