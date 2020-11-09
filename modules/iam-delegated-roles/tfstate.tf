data "terraform_remote_state" "primary_roles" {
  backend   = "s3"
  workspace = format("%s-%s", var.iam_roles_environment_name, var.iam_primary_roles_stage_name)

  config = {
    encrypt              = true
    bucket               = local.tfstate_bucket
    workspace_key_prefix = "iam-primary-roles"
    key                  = "terraform.tfstate"
    dynamodb_table       = local.tfstate_dynamodb_table
    region               = var.region
    role_arn             = local.tfstate_access_role_arn
    acl                  = "bucket-owner-full-control"
  }
}

data "terraform_remote_state" "tfstate" {
  count = module.this.stage == var.tfstate_backend_stage_name ? 1 : 0

  backend   = "s3"
  workspace = format("%s-%s", module.this.environment, var.tfstate_backend_stage_name)

  config = {
    encrypt              = true
    bucket               = local.tfstate_bucket
    workspace_key_prefix = "tfstate"
    key                  = "terraform.tfstate"
    region               = var.region
    role_arn             = local.tfstate_access_role_arn
    acl                  = "bucket-owner-full-control"
  }
}
