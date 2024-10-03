locals {
  enabled = module.this.enabled

  tags = module.this.tags

  datadog_api_key = module.datadog_configuration.datadog_api_key
  datadog_app_key = module.datadog_configuration.datadog_app_key
  datadog_site    = module.datadog_configuration.datadog_site

  # combine context tags with passed in datadog_tags
  # skip name since that won't be relevant for each metric
  datadog_tags = toset(distinct(concat([
    for k, v in module.this.tags : "${lower(k)}:${v}" if lower(k) != "name"
  ], tolist(var.datadog_tags))))

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
}

module "datadog_configuration" {
  source  = "../../datadog-configuration/modules/datadog_keys"
  context = module.this.context
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


module "datadog_agent" {
  source  = "cloudposse/helm-release/aws"
  version = "0.10.0"

  name          = module.this.name
  chart         = var.chart
  description   = var.description
  repository    = var.repository
  chart_version = var.chart_version

  kubernetes_namespace             = var.kubernetes_namespace
  create_namespace_with_kubernetes = var.create_namespace

  verify          = var.verify
  wait            = var.wait
  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  timeout         = var.timeout

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
    },
    {
      name  = "datadog.site"
      type  = "string"
      value = local.datadog_site
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
  ], local.set_datadog_cluster_checks)

  iam_role_enabled = false

  context = module.this.context
}
