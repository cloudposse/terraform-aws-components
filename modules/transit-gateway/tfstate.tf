data "terraform_remote_state" "vpc" {
  for_each = var.accounts_with_vpc

  backend   = "s3"
  workspace = "${module.this.environment}-${each.key}"

  config = {
    encrypt              = true
    bucket               = local.tfstate_bucket
    workspace_key_prefix = "vpc"
    key                  = "terraform.tfstate"
    dynamodb_table       = local.tfstate_dynamodb_table
    region               = var.region
    role_arn             = local.tfstate_access_role_arn
    acl                  = "bucket-owner-full-control"
  }
}

data "terraform_remote_state" "eks" {
  for_each = var.accounts_with_vpc

  backend   = "s3"
  workspace = "${module.this.environment}-${each.key}"

  config = {
    encrypt              = true
    bucket               = local.tfstate_bucket
    workspace_key_prefix = "eks"
    key                  = "terraform.tfstate"
    dynamodb_table       = local.tfstate_dynamodb_table
    region               = var.region
    role_arn             = local.tfstate_access_role_arn
    acl                  = "bucket-owner-full-control"
  }
}
