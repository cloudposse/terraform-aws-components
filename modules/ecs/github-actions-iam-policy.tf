locals {
  github_actions_iam_policy = join("", data.aws_iam_policy_document.github_actions_iam_policy.*.json)
}

data "aws_iam_policy_document" "github_actions_iam_policy" {
  count = var.github_actions_iam_role_enabled ? 1 : 0

  # This is an example access for GHA
  statement {
    sid    = "GitHubActionsROAccess"
    effect = "Allow"
    actions = [
      "ecs:DescribeClusters",
      "ecs:DescribeServices",
      "ecs:ListServices"
    ]

    resources = ["*"]
  }
}
