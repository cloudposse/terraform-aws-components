locals {
  enabled = module.this.enabled

  tags = module.this.tags

  datadog_api_key = module.datadog_configuration.datadog_api_key
  datadog_app_key = module.datadog_configuration.datadog_app_key

  # combine context tags with passed in datadog_tags
  # skip name since that won't be relevant for each metric
  datadog_tags = toset(distinct(concat([for k, v in module.this.tags : "${lower(k)}:${v}" if lower(k) != "name"], tolist(var.datadog_tags))))

  cluster_checks_enabled = local.enabled && var.cluster_checks_enabled

  context_tags = {
    for k, v in module.this.tags :
    lower(k) => v
  }

  deep_map_merge = local.cluster_checks_enabled ? module.datadog_cluster_check_yaml_config[0].map_configs : {}
  datadog_cluster_checks = {
    for k, v in local.deep_map_merge :
    k => merge(v, {
      instances = [
        for key, val in v.instances :
        merge(val, {
          tags = [
            for tag, tag_value in local.context_tags :
            format("%s:%s", tag, tag_value)
            if contains(var.datadog_cluster_check_auto_added_tags, tag)
          ]
        })
      ]
    })
  }
  set_datadog_cluster_checks = [
    for cluster_check_key, cluster_check_value in local.datadog_cluster_checks : {
      # Since we are using json pathing to set deep yaml values, and the key we want to set is `something.yaml`
      # we need to escape the key of the cluster check.
      name  = format("clusterAgent.confd.%s", replace(cluster_check_key, ".", "\\."))
      type  = "auto"
      value = yamlencode(cluster_check_value)
    }
  ]

  # This will match both datadog and datadog-cluster-agent service account names
  service_account_name = "datadog*"

  partition  = join("", data.aws_partition.current[*].partition)
  account_id = join("", data.aws_caller_identity.current[*].account_id)

  iam_role_arn = "arn:${local.partition}:iam::${local.account_id}:role/${module.this.id}-${trimsuffix(local.service_account_name, "*")}@${var.kubernetes_namespace}"

  set_datadog_irsa = var.iam_role_enabled ? [
    {
      name  = "clusterAgent.rbac.serviceAccountAnnotations.eks\\.amazonaws\\.com/role-arn"
      type  = "string"
      value = local.iam_role_arn
    },
    {
      name  = "agents.rbac.serviceAccountAnnotations.eks\\.amazonaws\\.com/role-arn"
      type  = "string"
      value = local.iam_role_arn
    },
  ] : []
}

module "datadog_configuration" {
  source = "../../datadog-configuration/modules/datadog_keys"

  global_environment_name = null

  context = module.this.context
}

data "aws_caller_identity" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}

module "datadog_cluster_check_yaml_config" {
  count = local.cluster_checks_enabled ? 1 : 0

  source  = "cloudposse/config/yaml"
  version = "1.0.2"

  map_config_local_base_path = path.module
  map_config_paths           = var.datadog_cluster_check_config_paths

  append_list_enabled = true

  parameters = merge(
    var.datadog_cluster_check_config_parameters,
    local.context_tags
  )

  context = module.this.context
}

module "values_merge" {
  source  = "cloudposse/config/yaml//modules/deepmerge"
  version = "1.0.2"

  # Merge in order: datadog values, var.values
  maps = [
    yamldecode(
      file("${path.module}/values.yaml")
    ),
    var.values,
  ]
}

resource "kubernetes_namespace" "default" {
  count = local.enabled && var.create_namespace ? 1 : 0

  metadata {
    name = var.kubernetes_namespace

    labels = local.tags
  }
}

module "datadog_agent" {
  source  = "cloudposse/helm-release/aws"
  version = "0.7.0"

  name                 = module.this.name
  chart                = var.chart
  description          = var.description
  repository           = var.repository
  chart_version        = var.chart_version
  kubernetes_namespace = var.kubernetes_namespace # join("", kubernetes_namespace.default[*].id)
  create_namespace     = false
  verify               = var.verify
  wait                 = var.wait
  atomic               = var.atomic
  cleanup_on_fail      = var.cleanup_on_fail
  timeout              = var.timeout

  eks_cluster_oidc_issuer_url = module.eks.outputs.eks_cluster_identity_oidc_issuer

  values = [
    yamlencode(module.values_merge.merged)
  ]

  set_sensitive = [
    {
      name  = "datadog.apiKey"
      type  = "string"
      value = local.datadog_api_key
    },
    {
      name  = "datadog.appKey"
      type  = "string"
      value = local.datadog_app_key
    }
  ]

  set = concat([
    {
      name  = "datadog.tags"
      type  = "auto"
      value = yamlencode(local.datadog_tags)
    },
    {
      name  = "datadog.clusterName"
      type  = "string"
      value = module.eks.outputs.eks_cluster_id
    },
  ], local.set_datadog_cluster_checks, local.set_datadog_irsa)

  iam_role_enabled = var.iam_role_enabled

  # Add the IAM role using set()
  service_account_role_arn_annotation_enabled = false

  # Dictates which ServiceAccounts are allowed to assume the IAM Role.
  service_account_name      = local.service_account_name
  service_account_namespace = var.kubernetes_namespace

  # IAM policy statements to add to the IAM role
  iam_policy_statements = var.iam_policy_statements

  depends_on = [kubernetes_namespace.default]

  context = module.this.context
}
