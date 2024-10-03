locals {
  enabled        = module.this.enabled
  context_labels = var.context_tags_enabled ? values(module.this.tags) : []

  webhook_enabled            = local.enabled ? try(var.webhook.enabled, false) : false
  webhook_host               = local.webhook_enabled ? format(var.webhook.hostname_template, var.tenant, var.stage, var.environment) : "example.com"
  runner_groups_enabled      = length(compact(values(var.runners)[*].group)) > 0
  docker_config_json_enabled = local.enabled && var.docker_config_json_enabled
  docker_config_json         = one(data.aws_ssm_parameter.docker_config_json[*].value)

  github_app_enabled = length(var.github_app_id) > 0 && length(var.github_app_installation_id) > 0
  create_secret      = local.enabled && length(var.existing_kubernetes_secret_name) == 0

  busy_metrics_filtered = { for runner, runner_config in var.runners : runner => try(runner_config.busy_metrics, null) == null ? null : {
    for k, v in runner_config.busy_metrics : k => v if v != null
  } }

  default_secrets = local.create_secret ? [
    {
      name  = local.github_app_enabled ? "authSecret.github_app_private_key" : "authSecret.github_token"
      value = one(data.aws_ssm_parameter.github_token[*].value)
      type  = "string"
    }
  ] : []

  webhook_secrets = local.create_secret && local.webhook_enabled ? [
    {
      name  = "githubWebhookServer.secret.github_webhook_secret_token"
      value = one(data.aws_ssm_parameter.github_webhook_secret_token[*].value)
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

data "aws_ssm_parameter" "github_token" {
  count = local.create_secret ? 1 : 0

  name            = var.ssm_github_secret_path
  with_decryption = true
}

data "aws_ssm_parameter" "github_webhook_secret_token" {
  count = local.create_secret && local.webhook_enabled ? 1 : 0

  name            = var.ssm_github_webhook_secret_token_path
  with_decryption = true
}

data "aws_ssm_parameter" "docker_config_json" {
  count           = local.docker_config_json_enabled ? 1 : 0
  name            = var.ssm_docker_config_json_path
  with_decryption = true
}

module "actions_runner_controller" {
  source  = "cloudposse/helm-release/aws"
  version = "0.10.1"

  name            = "" # avoids hitting length restrictions on IAM Role names
  chart           = var.chart
  repository      = var.chart_repository
  description     = var.chart_description
  chart_version   = var.chart_version
  wait            = var.wait
  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  timeout         = var.timeout

  kubernetes_namespace             = var.kubernetes_namespace
  create_namespace_with_kubernetes = var.create_namespace

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
      fullnameOverride = module.this.name
      serviceAccount = {
        name = module.this.name
      }
      resources = var.resources
      rbac = {
        create = var.rbac_enabled
      }
      replicaCount = var.controller_replica_count
      githubWebhookServer = {
        enabled                   = var.webhook.enabled
        queueLimit                = var.webhook.queue_limit
        useRunnerGroupsVisibility = local.runner_groups_enabled
        secret = {
          create = local.create_secret
        }
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
      }
      authSecret = {
        enabled = true
        create  = local.create_secret
      }
    }),
    local.github_app_enabled ? yamlencode({
      authSecret = {
        github_app_id              = var.github_app_id
        github_app_installation_id = var.github_app_installation_id
      }
    }) : "",
    local.create_secret ? "" : yamlencode({
      authSecret = {
        name = var.existing_kubernetes_secret_name
      },
      githubWebhookServer = {
        secret = {
          name = var.existing_kubernetes_secret_name
        }
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
  version = "0.10.1"

  name  = each.key
  chart = "${path.module}/charts/actions-runner"

  kubernetes_namespace = var.kubernetes_namespace
  create_namespace     = false # will be created by controller above
  atomic               = var.atomic

  eks_cluster_oidc_issuer_url = module.eks.outputs.eks_cluster_identity_oidc_issuer

  values = compact([
    yamlencode({
      release_name                   = each.key
      pod_annotations                = each.value.pod_annotations
      running_pod_annotations        = each.value.running_pod_annotations
      service_account_name           = module.actions_runner_controller.service_account_name
      type                           = each.value.type
      scope                          = each.value.scope
      image                          = each.value.image
      auto_update_enabled            = each.value.auto_update_enabled
      dind_enabled                   = each.value.dind_enabled
      service_account_role_arn       = module.actions_runner_controller.service_account_role_arn
      resources                      = each.value.resources
      docker_storage                 = each.value.docker_storage != null ? each.value.docker_storage : each.value.storage
      labels                         = concat(each.value.labels, local.context_labels)
      scale_down_delay_seconds       = each.value.scale_down_delay_seconds
      min_replicas                   = each.value.min_replicas
      max_replicas                   = each.value.max_replicas
      scheduled_overrides            = each.value.scheduled_overrides
      webhook_driven_scaling_enabled = each.value.webhook_driven_scaling_enabled
      max_duration                   = coalesce(each.value.webhook_startup_timeout, each.value.max_duration, "1h")
      wait_for_docker_seconds        = each.value.wait_for_docker_seconds
      pull_driven_scaling_enabled    = each.value.pull_driven_scaling_enabled
      pvc_enabled                    = each.value.pvc_enabled
      tmpfs_enabled                  = each.value.tmpfs_enabled
      node_selector                  = each.value.node_selector
      affinity                       = each.value.affinity
      tolerations                    = each.value.tolerations
      docker_config_json_enabled     = local.docker_config_json_enabled
      docker_config_json             = local.docker_config_json
    }),
    each.value.group == null ? "" : yamlencode({ group = each.value.group }),
    local.busy_metrics_filtered[each.key] == null ? "" : yamlencode(local.busy_metrics_filtered[each.key]),
  ])

  depends_on = [module.actions_runner_controller]
}
