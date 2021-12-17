locals {
  enabled                     = module.this.enabled
  eks_cluster_oidc_issuer_url = module.eks.outputs["eks_cluster_identity_oidc_issuer"]
  enabled_iam_role            = local.enabled && var.iam_role_enabled
  # Loop through each supplied runner_configuration to determine if the runner is an organization (org) or repository (repo) runner type
  runners = [for r in var.runner_configurations : merge(r, tomap({
    "type"   = lower(coalesce(contains(keys(r), "repo") ? "repo" : "", contains(keys(r), "org") ? "org" : "")),
    "target" = coalesce(lookup(r, "org", ""), lookup(r, "repo", ""))
    }))
  ]
}

data "aws_caller_identity" "current" {
  count = local.enabled ? 1 : 0
}
data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}

module "github_action_controller_label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  attributes = ["github-actions-controller"]
}

# You cannot have a directory with the same name as the chart you are installing from repo
# https://github.com/hashicorp/terraform-provider-helm/issues/735
module "actions_runner_controller" {
  source  = "cloudposse/helm-release/aws"
  version = "0.3.0"

  name    = var.controller_chart_release_name # module.github_action_controller_label.tags["Attributes"]
  enabled = local.enabled

  repository    = var.controller_chart_repo
  chart         = var.controller_chart_name
  chart_version = var.controller_chart_version

  create_namespace     = var.controller_chart_namespace_create
  kubernetes_namespace = var.controller_chart_namespace

  iam_role_enabled    = local.enabled_iam_role
  iam_source_json_url = var.iam_source_json_url

  eks_cluster_oidc_issuer_url                 = local.eks_cluster_oidc_issuer_url
  service_account_name                        = var.service_account_name
  service_account_namespace                   = var.service_account_namespace
  service_account_role_arn_annotation_enabled = true

  # These values will be deep merged
  values = [
    # remove comments
    yamlencode(yamldecode(
      file("${path.module}/runners/actions-runner-controller/values.yaml"))
    ),
    yamlencode(var.controller_chart_values),
  ]

  set = [
    {
      name  = "image.repository"
      value = var.controller_chart_image
      type  = "string"
    },
    {
      name  = "image.tag"
      value = var.controller_chart_image_tag
      type  = "string"
    },
    {
      name  = "serviceAccount.name"
      value = "github-action-runner"
      type  = "string"
    },
  ]

  iam_policy_statements = flatten([var.iam_policy_statements, [
    {
      sid    = "EcrReadWriteDeleteAccess"
      effect = "Allow"

      actions = [
        # This is intended to be everything except create/delete repository
        # and get/set/delete repositoryPolicy
        "ecr:GetAuthorizationToken",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage",
        "ecr:PutImageTagMutability",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
        "ecr:DescribeImageScanFindings",
        "ecr:StartImageScan",
        "ecr:BatchDeleteImage",
        "ecr:TagResource",
        "ecr:UntagResource",
        "ecr:GetLifecyclePolicy",
        "ecr:PutLifecyclePolicy",
        "ecr:StartLifecyclePolicyPreview",
        "ecr:GetLifecyclePolicyPreview",
        "ecr:DeleteLifecyclePolicy",
        "ecr:PutImageScanningConfiguration",
      ]
      resources = ["*"]
    },
    {
      sid = "AssumeRoles"

      actions = [
        "sts:AssumeRole",
        "sts:TagSession",
      ]

      effect    = "Allow"
      resources = [module.iam_primary_roles.outputs.role_name_role_arn_map["cicd"]]
    },
    {
      sid = "AllowGithubActionRunnersSSMAccess"

      actions = [
        "ssm:DescribeParameters"
      ]

      effect    = "Allow"
      resources = ["*"]
    },
    {
      sid = "AllowGithubActionRunnersSSMReadAccess"

      actions = [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath"
      ]

      effect = "Allow"

      resources = [
        format(
          "arn:%s:ssm:%s:%s:parameter/github-action/secrets/*",
          join("", data.aws_partition.current.*.partition),
          var.region,
          join("", data.aws_caller_identity.current.*.account_id)
        )
      ]
    },
    {
      sid = "AllowGithubActionRunnersToDecrypt"

      actions = [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:GenerateDataKey*"
      ]

      effect = "Allow"
      resources = [
        aws_kms_key.github_action_runner[0].arn
      ]
    }
  ]])
}

module "github_action_helm_label" {
  count = local.enabled ? length(local.runners) : 0

  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.this.context
  attributes = [
    local.runners[count.index]["type"],
    replace(local.runners[count.index]["target"], "/", "-"),
  ]
}

module "actions_runner" {
  source  = "cloudposse/helm-release/aws"
  version = "0.3.0"

  depends_on = [
    module.actions_runner_controller
  ]

  count = local.enabled ? length(local.runners) : 0

  name       = module.github_action_helm_label[count.index].tags["Attributes"]
  repository = var.controller_chart_repo
  chart      = "${path.module}/runners/actions-runner/chart"

  create_namespace     = true
  kubernetes_namespace = "actions-runner-system"

  # These values will be deep merged
  values = [
    yamlencode({
      autoscale            = var.autoscale_types[var.autoscale_type]
      release_name         = module.github_action_helm_label[count.index].tags["Attributes"]
      role_arn             = module.actions_runner_controller.service_account_role_arn
      runner_resources     = var.runner_types[coalesce(lookup(local.runners[count.index], "runner_type", ""), var.runner_type)]
      runners_image        = var.runner_chart_image
      service_account_name = "github-action-runner"
      target               = local.runners[count.index]["target"]
      type                 = local.runners[count.index]["type"]
    }),
    yamlencode(var.runner_chart_values),
  ]
}
