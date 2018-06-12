#!/usr/bin/env bash

## Spaces before and after `backend` required to select right word, because `backend` appears 3 times in main.tf
sed -i "s/ backend / #backend /" main.tf
sed -i "s/ role_arn / #role_arn /" main.tf


init-terraform
terraform plan

export TF_BUCKET=$(echo "yes" | terraform apply | grep -o -e "tfstate_backend_s3_bucket_id\s=\s.*" | cut -d ' ' -f 3)
export TF_BUCKET_REGION=${TF_VAR_region}

## Spaces before and after `backend` required to select right word, because `backend` appears 3 times in main.tf
sed -i "s/ #backend / backend /" main.tf

echo "yes" | init-terraform

sed -i "s/ #role_arn / role_arn /" main.tf

echo "Add to the Geodesic Module Dockerfile following"
echo "#----------------------------------------------"
echo "ENV TF_BUCKET=\"${TF_BUCKET}\""
echo "ENV TF_BUCKET_REGION=\"${TF_BUCKET_REGION}\""
echo "#----------------------------------------------"
echo "And rebuild the module"
