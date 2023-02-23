
data "aws_iam_policy_document" "TerraformUpdateAccess" {
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
  terraform_update_access_permission_set = [{
    name                                = "TerraformUpdateAccess",
    description                         = "Allow access to Terraform state sufficient to make changes",
    relay_state                         = "",
    session_duration                    = "PT1H", # One hour, maximum allowed for chained assumed roles
    tags                                = {},
    inline_policy                       = data.aws_iam_policy_document.TerraformUpdateAccess.json,
    policy_attachments                  = []
    customer_managed_policy_attachments = []
  }]
}
