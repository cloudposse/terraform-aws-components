module "iam_role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.19.0"

  principals = {
    "Service" = ["glue.amazonaws.com"]
  }

  managed_policy_arns   = var.iam_managed_policy_arns
  role_description      = var.iam_role_description
  policy_description    = var.iam_policy_description
  policy_document_count = 0

  context = module.this.context
}
