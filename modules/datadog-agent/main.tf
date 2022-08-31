locals {
  enabled = module.this.enabled

  tags = module.introspection.tags

  datadog_api_key = local.enabled ? (var.secrets_store_type == "ASM" ? (
    data.aws_secretsmanager_secret_version.datadog_api_key[0].secret_string) :
    data.aws_ssm_parameter.datadog_api_key[0].value
  ) : null

  datadog_app_key = local.enabled ? (var.secrets_store_type == "ASM" ? (
    data.aws_secretsmanager_secret_version.datadog_app_key[0].secret_string) :
    data.aws_ssm_parameter.datadog_app_key[0].value
  ) : null

  # combine context tags with passed in datadog_tags
  # skip name since that won't be relevant for each metric
  datadog_tags = distinct(concat([for k, v in module.this.tags : "${lower(k)}:${v}" if lower(k) != "name"], var.datadog_tags))


  cluster_checks_enabled = local.enabled && var.cluster_checks_enabled

  context_tags = {
    for k, v in module.this.tags :
    lower(k) => v
  }

  #  This deep merges the cluster checks with array merging
  deep_map_merge = module.datadog_cluster_check_yaml_config[0].map_configs
  #  We then take the merged instances and merge tags onto every instance check for every tag in `datadog_cluster_check_auto_added_tags`
  datadog_cluster_checks = {
    for k, v in local.deep_map_merge :
    k => merge(v, {
      instances : [
        for key, val in v.instances :
        merge(val, {
          tags : [
            for tag, tag_value in local.context_tags :
            format("%s:%s", tag, tag_value)
            if contains(var.datadog_cluster_check_auto_added_tags, tag)
          ]
        })
      ]
    })
  }
  #  This then turns the map of root keys to objects, into an array so we can concat it in the set block.
  set_datadog_cluster_checks = [
    for cluster_check_key, cluster_check_value in local.datadog_cluster_checks :
    {
      # Since we are using json pathing to set deep yaml values, and the key we want to set is `something.yaml`
      # we need to escape the key of the cluster check.
      name  = format("clusterAgent.confd.%s", replace(cluster_check_key, ".", "\\."))
      type  = "auto"
      value = yamlencode(cluster_check_value)
    }
  ]
}


module "datadog_cluster_check_yaml_config" {
  count = local.cluster_checks_enabled ? 1 : 0

  source  = "cloudposse/config/yaml"
  version = "1.0.1"

  map_config_local_base_path = path.module
  map_config_paths           = var.datadog_cluster_check_config_paths

  append_list_enabled = true

  parameters = merge(
    var.datadog_cluster_check_config_parameters,
    local.context_tags
  )

  context = module.this.context
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
  version = "0.3.2"

  name                 = module.this.name
  chart                = var.chart
  description          = var.description
  repository           = var.repository
  chart_version        = var.chart_version
  kubernetes_namespace = join("", kubernetes_namespace.default.*.id)
  create_namespace     = false
  verify               = var.verify
  wait                 = var.wait
  atomic               = var.atomic
  cleanup_on_fail      = var.cleanup_on_fail
  timeout              = var.timeout

  values = [
    file("${path.module}/resources/values.yaml")
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
    }
  ], local.set_datadog_cluster_checks)

  depends_on = [kubernetes_namespace.default]

}
