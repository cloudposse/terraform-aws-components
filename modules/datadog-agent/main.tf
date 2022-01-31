locals {
  enabled = module.this.enabled

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
}

module "datadog_agent" {
  source  = "cloudposse/helm-release/aws"
  version = "0.3.0"

  name             = module.this.name
  chart            = var.chart
  description      = var.description
  repository       = var.repository
  chart_version    = var.chart_version
  namespace        = var.kubernetes_namespace
  create_namespace = var.create_namespace
  verify           = var.verify
  wait             = var.wait
  atomic           = var.atomic
  cleanup_on_fail  = var.cleanup_on_fail
  timeout          = var.timeout

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

  set = [{
    name  = "datadog.tags"
    type  = "auto"
    value = yamlencode(local.datadog_tags)
  }]

  context = module.this.context
}
