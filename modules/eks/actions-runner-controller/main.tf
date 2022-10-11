locals {
  enabled               = module.this.enabled
  identity_account_name = module.account_map.outputs.identity_account_account_name
  identity_account_id   = module.account_map.outputs.full_account_map[local.identity_account_name]
  stack_name            = local.enabled ? format("${module.this.tenant != null ? "%[1]s-" : ""}%[2]s-%[3]s", module.this.tenant, module.this.environment, module.this.stage) : ""
  webhook_enabled       = local.enabled ? try(var.webhook.enabled, false) : false
  webhook_host          = local.webhook_enabled ? format(var.webhook.hostname_template, var.tenant, var.stage, var.environment) : "example.com"

  default_secrets = local.enabled ? [
    {
      name  = "authSecret.github_token"
      value = join("", data.aws_ssm_parameter.github_token[0].*.value)
      type  = "string"
    }
  ] : []

  webhook_secrets = local.webhook_enabled ? [
    {
      name  = "githubWebhookServer.secret.github_webhook_secret_token"
      value = join("", data.aws_ssm_parameter.github_webhook_secret_token[0].*.value)
      type  = "string"
    }
  ] : []

  set_sensitive = concat(local.default_secrets, local.webhook_secrets)

  default_iam_policy_statements = [
    {
      sid = "AllowECRActions"
      actions = [
        # This is intended to be everything except create/delete repository
        # and get/set/delete repositoryPolicy
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchDeleteImage",
        "ecr:BatchGetImage",
        "ecr:CompleteLayerUpload",
        "ecr:DeleteLifecyclePolicy",
        "ecr:DescribeImages",
        "ecr:DescribeImageScanFindings",
        "ecr:DescribeRepositories",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetLifecyclePolicy",
        "ecr:GetLifecyclePolicyPreview",
        "ecr:GetRepositoryPolicy",
        "ecr:InitiateLayerUpload",
        "ecr:ListImages",
        "ecr:PutImage",
        "ecr:PutImageScanningConfiguration",
        "ecr:PutImageTagMutability",
        "ecr:PutLifecyclePolicy",
        "ecr:StartImageScan",
        "ecr:StartLifecyclePolicyPreview",
        "ecr:TagResource",
        "ecr:UntagResource",
        "ecr:UploadLayerPart",
      ]
      resources = ["*"]
    }
  ]

  s3_iam_policy_statements = length(var.s3_bucket_arns) > 0 ? [
    {
      sid = "AllowS3Actions"
      actions = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObjectVersion",
        "s3:ListBucket",
        "s3:DeleteObject",
        "s3:PutObjectAcl"
      ]
      resources = flatten([
        for arn in var.s3_bucket_arns :
        [arn, "${arn}/*"]
      ])
    },
  ] : []

  iam_policy_statements = concat(local.default_iam_policy_statements, local.s3_iam_policy_statements)
}

data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_ssm_parameter" "github_token" {
  count = local.enabled ? 1 : 0

  name            = var.ssm_github_token_path
  with_decryption = true
}

data "aws_ssm_parameter" "github_webhook_secret_token" {
  count = local.webhook_enabled ? 1 : 0

  name            = var.ssm_github_webhook_secret_token_path
  with_decryption = true
}

module "actions_runner_controller" {
  source  = "cloudposse/helm-release/aws"
  version = "0.6.0"

  name                 = "" # avoids hitting length restrictions on IAM Role names
  chart                = var.chart
  repository           = var.chart_repository
  description          = var.chart_description
  chart_version        = var.chart_version
  kubernetes_namespace = var.kubernetes_namespace
  create_namespace     = var.create_namespace
  wait                 = var.wait
  atomic               = var.atomic
  cleanup_on_fail      = var.cleanup_on_fail
  timeout              = var.timeout

  eks_cluster_oidc_issuer_url = module.eks.outputs.eks_cluster_identity_oidc_issuer

  service_account_name      = module.this.name
  service_account_namespace = var.kubernetes_namespace

  iam_role_enabled = true

  iam_policy_statements = local.iam_policy_statements

  values = compact([
    # hardcoded values
    file("${path.module}/resources/values.yaml"),
    # standard k8s object settings
    yamlencode({
      fullnameOverride = module.this.name,
      serviceAccount = {
        name = module.this.name
      },
      resources = var.resources
      rbac = {
        create = var.rbac_enabled
      }
      githubWebhookServer = {
        enabled = var.webhook.enabled
        ingress = {
          enabled = var.webhook.enabled
          hosts = [
            {
              host = local.webhook_host
              paths = [
                {
                  path     = "/"
                  pathType = "Prefix"
                }
              ]
            }
          ]
        }
      },
      authSecret = {
        enabled = true
        create  = true
      }
    }),
    # additional values
    yamlencode(var.chart_values)
  ])

  set_sensitive = local.set_sensitive

  context = module.this.context
}

module "actions_runner" {
  for_each = local.enabled ? var.runners : {}

  source  = "cloudposse/helm-release/aws"
  version = "0.6.0"

  name  = each.key
  chart = "${path.module}/charts/actions-runner"

  kubernetes_namespace = var.kubernetes_namespace
  create_namespace     = var.create_namespace
  atomic               = var.atomic

  eks_cluster_oidc_issuer_url = module.eks.outputs.eks_cluster_identity_oidc_issuer

  values = [
    yamlencode({
      release_name                   = each.key
      service_account_name           = module.actions_runner_controller.service_account_name
      type                           = each.value.type
      scope                          = each.value.scope
      image                          = each.value.image
      dind_enabled                   = each.value.dind_enabled
      service_account_role_arn       = module.actions_runner_controller.service_account_role_arn
      resources                      = each.value.resources
      storage                        = each.value.storage
      labels                         = each.value.labels
      scale_down_delay_seconds       = each.value.scale_down_delay_seconds
      min_replicas                   = each.value.min_replicas
      max_replicas                   = each.value.max_replicas
      scale_up_threshold             = try(each.value.busy_metrics.scale_up_threshold, null)
      scale_down_threshold           = try(each.value.busy_metrics.scale_down_threshold, null)
      scale_up_adjustment            = try(each.value.busy_metrics.scale_up_adjustment, null)
      scale_down_adjustment          = try(each.value.busy_metrics.scale_down_adjustment, null)
      scale_up_factor                = try(each.value.busy_metrics.scale_up_factor, null)
      scale_down_factor              = try(each.value.busy_metrics.scale_down_factor, null)
      webhook_driven_scaling_enabled = each.value.webhook_driven_scaling_enabled
      pull_driven_scaling_enabled    = each.value.pull_driven_scaling_enabled
    })
  ]

  depends_on = [module.actions_runner_controller]
}

