data "terraform_remote_state" "accounts" {
  backend   = "s3"
  workspace = "${module.this.environment}-${module.this.stage}"

  config = {
    encrypt              = true
    bucket               = local.tfstate_bucket
    workspace_key_prefix = "account"
    key                  = "terraform.tfstate"
    dynamodb_table       = local.tfstate_dynamodb_table
    region               = var.region
    role_arn             = local.tfstate_access_role_arn
    acl                  = "bucket-owner-full-control"
  }
}
