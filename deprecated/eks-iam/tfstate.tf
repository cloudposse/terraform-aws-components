data "terraform_remote_state" "eks" {
  backend   = "s3"
  workspace = terraform.workspace

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

data "terraform_remote_state" "account_map" {
  backend   = "s3"
  workspace = format("%s-%s", var.account_map_environment_name, var.account_map_stage_name)

  config = {
    encrypt              = true
    bucket               = local.tfstate_bucket
    workspace_key_prefix = "account-map"
    key                  = "terraform.tfstate"
    dynamodb_table       = local.tfstate_dynamodb_table
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
    workspace_key_prefix = "dns-delegated"
    key                  = "terraform.tfstate"
    dynamodb_table       = local.tfstate_dynamodb_table
    region               = var.region
    role_arn             = local.tfstate_access_role_arn
    acl                  = "bucket-owner-full-control"
  }
}

data "terraform_remote_state" "dns_gbl_delegated" {
  backend   = "s3"
  workspace = format("%s-%s", var.dns_gbl_delegated_environment_name, module.this.stage)

  config = {
    encrypt              = true
    bucket               = local.tfstate_bucket
    workspace_key_prefix = "dns-delegated"
    key                  = "terraform.tfstate"
    dynamodb_table       = local.tfstate_dynamodb_table
    region               = var.region
    role_arn             = local.tfstate_access_role_arn
    acl                  = "bucket-owner-full-control"
  }
}

locals {
  default_dns_zone_id = data.terraform_remote_state.dns_delegated.outputs.default_dns_zone_id

  zone_ids = compact(concat(
    values(data.terraform_remote_state.dns_delegated.outputs.zones)[*].zone_id,
    values(data.terraform_remote_state.dns_gbl_delegated.outputs.zones)[*].zone_id
  ))
}
