#!/usr/bin/env bash

sed -i "s/backend(\s+)\"s3\"/#backend\ 1 \"s3\"/" main.tf

init-terraform
terraform plan

export TF_BUCKET=$(echo "yes" | terraform apply | grep -o -e "tfstate_backend_s3_bucket_id\s=\s.*" | cut -d ' ' -f 3)
export TF_BUCKET_REGION=${TF_VAR_region}

sed -i "s/#backend(\s+)\"s3\"/backend\ 1 \"s3\"/" main.tf

s3 fstab "${TF_BUCKET}" '/' '/secrets/tf'

echo "yes" | init-terraform


echo "Add to the Geodesic Module Dockerfile following"
echo "#----------------------------------------------"
echo "ENV TF_BUCKET=\"${TF_BUCKET}\""
echo "ENV TF_BUCKET_REGION=\"${TF_BUCKET_REGION}\""
echo "#----------------------------------------------"
echo "And rebuild the module"
