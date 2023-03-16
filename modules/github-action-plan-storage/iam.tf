module "github_action_role" {
  source  = "../account-map/modules/team-assume-role-policy"
  enabled = true
  context = module.this.context
  stage   = var.oidc_provilder_stage

  trusted_github_repos = var.trusted_github_repos
  trusted_github_org   = var.trusted_github_org

}

resource "aws_iam_role" "default" {
  assume_role_policy = module.github_action_role.github_assume_role_policy
  inline_policy {
    name   = "bucket_and_dynamodb_access"
    policy = data.aws_iam_policy_document.bucket_and_dynamodb_access.json
  }
}

data "aws_iam_policy_document" "bucket_and_dynamodb_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      module.tfstate_backend.tfstate_backend_s3_bucket_arn,
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]
    resources = [
      "${module.tfstate_backend.tfstate_backend_s3_bucket_arn}/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan",
    ]
    resources = [
      module.tfstate_backend.tfstate_backend_dynamodb_table_arn,
      join("", aws_dynamodb_table.default.*.arn)
    ]
  }
}
