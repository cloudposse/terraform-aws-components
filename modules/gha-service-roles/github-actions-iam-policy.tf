locals {
  enabled = module.this.enabled
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = var.aws_iam_policy_statements
  })
  github_actions_iam_policy = local.policy
}
