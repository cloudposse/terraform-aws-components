data "terraform_remote_state" "vpc" {
  backend   = "s3"
  workspace = terraform.workspace

  config = {
    encrypt              = true
    bucket               = local.tfstate_bucket
    key                  = "terraform.tfstate"
    dynamodb_table       = local.tfstate_dynamodb_table
    workspace_key_prefix = "vpc"
    region               = var.region
    role_arn             = local.tfstate_access_role_arn
    acl                  = "bucket-owner-full-control"
  }
}

data "terraform_remote_state" "eks" {
  backend   = "s3"
  workspace = terraform.workspace

  config = {
    encrypt              = true
    bucket               = local.tfstate_bucket
    key                  = "terraform.tfstate"
    dynamodb_table       = local.tfstate_dynamodb_table
    workspace_key_prefix = "eks"
    region               = var.region
    role_arn             = local.tfstate_access_role_arn
    acl                  = "bucket-owner-full-control"
  }
}

data "terraform_remote_state" "dns_delegated" {
  backend   = "s3"
  workspace = terraform.workspace

  config = {
    encrypt              = true
    bucket               = local.tfstate_bucket
    key                  = "terraform.tfstate"
    dynamodb_table       = local.tfstate_dynamodb_table
    workspace_key_prefix = "dns-delegated"
    region               = var.region
    role_arn             = local.tfstate_access_role_arn
    acl                  = "bucket-owner-full-control"
  }
}
