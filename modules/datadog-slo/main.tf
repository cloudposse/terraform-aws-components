locals {
  enabled = module.this.enabled

  datadog_api_key = (var.secrets_store_type == "ASM" ? (
    data.aws_secretsmanager_secret_version.datadog_api_key[0].secret_string) :
    data.aws_ssm_parameter.datadog_api_key[0].value
  )

  datadog_app_key = (var.secrets_store_type == "ASM" ? (
    data.aws_secretsmanager_secret_version.datadog_app_key[0].secret_string) :
    data.aws_ssm_parameter.datadog_app_key[0].value
  )

  slo_files = flatten([for p in var.slo_paths : fileset(path.module, p)])
  slo_list  = [for f in local.slo_files : yamldecode(file(f))]
  slo_map   = merge(local.slo_list...)

}

module "datadog_slos" {
  source  = "cloudposse/platform/datadog//modules/slo"

  datadog_slos = local.slo_map
  alert_tags = var.alert_tags
  alert_tags_separator = var.alert_tags_separator

  enabled = var.enabled
  context = module.this.context
}
