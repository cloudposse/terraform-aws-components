#!/usr/bin/env bash

## Spaces before and after `backend` required to select right word, because `backend` appears 3 times in main.tf
sed -Ei 's/^(\s+role_arn\s+)/#\1/' main.tf

init-terraform

terraform apply -input=false -auto-approve

sed -Ei 's/^#(\s+role_arn\s+)/\1/' main.tf

echo "Root IAM Role provisioned"
