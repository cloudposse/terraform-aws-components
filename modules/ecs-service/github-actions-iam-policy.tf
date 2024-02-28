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
    join("", data.aws_iam_policy_document.github_actions_iam_ecspresso_policy[*]["json"])
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

  # Allow chamber to read secrets
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
    resources = concat([
      "arn:aws:ssm:*:*:parameter${format("/%s/%s/*", var.chamber_service, var.name)}"
    ], formatlist("arn:aws:ssm:*:*:parameter%s", keys(local.url_params)))
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

data "aws_caller_identity" "current" {}

locals {
  aws_partition = module.iam_roles.aws_partition
  account_id    = data.aws_caller_identity.current.account_id
}

data "aws_iam_policy_document" "github_actions_iam_ecspresso_policy" {
  count = var.github_actions_ecspresso_enabled ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "ecs:DescribeServices",
      "ecs:UpdateService",
      "ecs:ListTagsForResource"
    ]
    resources = [
      join("", module.ecs_alb_service_task[*]["service_arn"])
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecs:RunTask",
    ]
    resources = [
      format("arn:%s:ecs:%s:%s:task-definition/%s:*", local.aws_partition, var.region, local.account_id, join("", module.ecs_alb_service_task.*.task_definition_family)),
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecs:RegisterTaskDefinition",
      "ecs:TagResource",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "application-autoscaling:DescribeScalableTargets"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "logs"
    effect = "Allow"
    actions = [
      "logs:Describe*",
      "logs:Get*",
      "logs:List*",
      "logs:StartQuery",
      "logs:StopQuery",
      "logs:TestMetricFilter",
      "logs:FilterLogEvents",
      "oam:ListSinks"
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
      join("", module.ecs_alb_service_task[*]["task_exec_role_arn"]),
      join("", module.ecs_alb_service_task[*]["task_role_arn"]),
    ]
  }

  dynamic "statement" {
    for_each = local.s3_mirroring_enabled ? ["enabled"] : []
    content {
      effect    = "Allow"
      actions   = ["s3:ListBucket"]
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = local.s3_mirroring_enabled ? ["enabled"] : []
    content {
      effect = "Allow"
      actions = [
        "s3:PutObject"
      ]
      resources = [
        format("%s/%s/%s/*", lookup(module.s3[0].outputs, "bucket_arn", null), module.ecs_cluster.outputs.cluster_name, module.this.id)
      ]
    }
  }
}
