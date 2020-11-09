data "terraform_remote_state" "eks-iam" {
  for_each = var.cicd_accounts

  backend   = "s3"
  workspace = "${module.this.environment}-${each.key}"

  config = {
    encrypt              = true
    bucket               = local.tfstate_bucket
    key                  = "terraform.tfstate"
    dynamodb_table       = local.tfstate_dynamodb_table
    workspace_key_prefix = "eks-iam"
    region               = var.region
    role_arn             = local.tfstate_access_role_arn
  }

  defaults = {
    cicd_roles = []
  }
}
