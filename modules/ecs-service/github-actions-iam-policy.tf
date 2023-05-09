variable "github_oidc_trusted_role_arns" {
  type        = list(string)
  description = "A list of IAM Role ARNs allowed to assume this cluster's GitHub OIDC role"
  default     = []
}

variable "github_actions_ecspresso_enabled" {
  type        = bool
  description = "Create IAM policies required for deployments with Ecspresso"
  default     = false
}

locals {
  github_actions_iam_policy = data.aws_iam_policy_document.github_actions_iam_policy.json
}

data "aws_iam_policy_document" "github_actions_iam_policy" {
  source_policy_documents = compact([
    data.aws_iam_policy_document.github_actions_iam_platform_policy.json,
    join("", data.aws_iam_policy_document.github_actions_iam_ecspresso_policy.*.json)
  ])
}

data "aws_iam_policy_document" "github_actions_iam_platform_policy" {
  # Allows trusted roles to assume this role
  dynamic "statement" {
    for_each = length(var.github_oidc_trusted_role_arns) == 0 ? [] : ["enabled"]
    content {
      sid    = "TrustedRoleAccess"
      effect = "Allow"
      actions = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
      resources = var.github_oidc_trusted_role_arns
    }
  }

  statement {
    sid    = "AllowKMSAccess"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    #bridgecrew:skip=BC_AWS_IAM_57:OK Allow to Decrypt with any key.
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "ssm:GetParameter",
      "ssm:PutParameter"
    ]
    resources = [
      "arn:aws:ssm:*:*:parameter${format("/%s/%s/*", var.chamber_service, var.name)}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:DescribeParameters",
      "ssm:GetParametersByPath"
    ]
    #bridgecrew:skip=BC_AWS_IAM_57:OK Allow to read from any ssm parameter store for chamber.
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "github_actions_iam_ecspresso_policy" {
  count = var.github_actions_ecspresso_enabled ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "ecs:DescribeServices",
      "ecs:UpdateService"
    ]
    resources = [
      join("", module.ecs_alb_service_task.*.service_arn)
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecs:RegisterTaskDefinition"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      join("", module.ecs_alb_service_task.*.task_exec_role_arn),
      join("", module.ecs_alb_service_task.*.task_role_arn),
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "application-autoscaling:DescribeScalableTargets"
    ]
    resources = [
      "*",
    ]
  }


}
