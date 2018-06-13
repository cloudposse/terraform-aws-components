#!/usr/bin/env bash

## Spaces before and after `backend` required to select right word, because `backend` appears 3 times in main.tf
sed -i "s/ role_arn / #role_arn /" main.tf

init-terraform
terraform plan
echo "yes" | terraform apply

sed -i "s/ #role_arn / role_arn /" main.tf

echo "Organizations provisioned"
