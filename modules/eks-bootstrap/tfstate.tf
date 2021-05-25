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

data "terraform_remote_state" "delegated_roles" {
  backend   = "s3"
  workspace = format("%s-%s", var.iam_roles_environment_name, module.this.stage)

  config = {
    encrypt              = true
    bucket               = local.tfstate_bucket
    workspace_key_prefix = "iam-delegated-roles"
    key                  = "terraform.tfstate"
    dynamodb_table       = local.tfstate_dynamodb_table
    region               = var.region
    role_arn             = local.tfstate_access_role_arn
    acl                  = "bucket-owner-full-control"
  }
}

data "terraform_remote_state" "vpc" {
  backend   = "s3"
  workspace = terraform.workspace

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

# Yes, this is self-referential.
# It obtains the previous state of the cluster so that we can add
# to it rather than overwrite it (specifically the aws-auth configMap)
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

  defaults = {
    eks_managed_node_workers_role_arns = []
  }
}
