variable "tfstate_environment_name" {
  type        = string
  description = "The name of the environment where `tfstate-backend` is provisioned. If not set, the TerraformUpdateAccess permission set will not be created."
  default     = null
}

locals {
  tf_update_access_enabled = var.tfstate_environment_name != null && module.this.enabled
}

module "tfstate" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  bypass = !local.tf_update_access_enabled

  component   = "tfstate-backend"
  environment = var.tfstate_environment_name
  stage       = module.iam_roles.global_stage_name
  privileged  = var.privileged

  context = module.this.context
}

data "aws_iam_policy_document" "terraform_update_access" {
  count = local.tf_update_access_enabled ? 1 : 0

  statement {
    sid     = "TerraformStateBackendS3Bucket"
    effect  = "Allow"
    actions = ["s3:ListBucket", "s3:GetObject", "s3:PutObject"]
    resources = module.this.enabled ? [
      module.tfstate.outputs.tfstate_backend_s3_bucket_arn,
      "${module.tfstate.outputs.tfstate_backend_s3_bucket_arn}/*"
    ] : []
  }
  statement {
    sid       = "TerraformStateBackendDynamoDbTable"
    effect    = "Allow"
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
    resources = module.this.enabled ? [module.tfstate.outputs.tfstate_backend_dynamodb_table_arn] : []
  }
}

locals {
  terraform_update_access_permission_set = local.tf_update_access_enabled ? [{
    name                                = "TerraformUpdateAccess",
    description                         = "Allow access to Terraform state sufficient to make changes",
    relay_state                         = "",
    session_duration                    = "PT1H", # One hour, maximum allowed for chained assumed roles
    tags                                = {},
    inline_policy                       = one(data.aws_iam_policy_document.terraform_update_access[*].json),
    policy_attachments                  = []
    customer_managed_policy_attachments = []
  }] : []
}
