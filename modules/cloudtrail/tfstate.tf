data "terraform_remote_state" "cloudtrail_bucket" {
  backend   = "s3"
  workspace = "${module.this.environment}-${var.cloudtrail_bucket_stage_name}"

  config = {
    encrypt              = true
    bucket               = local.tfstate_bucket
    key                  = "terraform.tfstate"
    dynamodb_table       = local.tfstate_dynamodb_table
    workspace_key_prefix = "cloudtrail-bucket"
    region               = var.region
    role_arn             = local.tfstate_access_role_arn
    acl                  = "bucket-owner-full-control"
  }
}
