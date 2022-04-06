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

  datadog_synthetics_private_location_id = module.datadog_synthetics_private_location[0].outputs.synthetics_private_location_id

  # Only return context tags that are specified
  context_tags = var.context_tags_enabled ? {
    for k, v in module.this.tags :
    lower(k) => v
    if contains(var.context_tags, lower(k))
  } : {}

  # For deep merge
  context_tags_in_tags = var.context_tags_enabled ? {
    tags = local.context_tags
  } : {}

  synthetics_merged = {
    for k, v in module.datadog_synthetics_merge :
    k => v.merged
  }
}

# Convert all Datadog Monitors from YAML config to Terraform map
module "datadog_synthetics_yaml_config" {
  count = local.enabled ? 1 : 0

  source  = "cloudposse/config/yaml"
  version = "0.8.1"

  map_config_local_base_path = path.module
  map_config_paths           = var.synthetics_paths

  parameters = merge(var.config_parameters, local.context_tags)

  context = module.this.context
}

module "datadog_synthetics_merge" {
  source  = "cloudposse/config/yaml//modules/deepmerge"
  version = "0.4.0"

  for_each = local.enabled ? module.datadog_synthetics_yaml_config[0].map_configs : {}

  # Merge in order: 1) datadog monitor, datadog monitor globals, context tags
  maps = [
    each.value,
    var.datadog_synthetics_globals,
    local.context_tags_in_tags,
  ]
}

module "datadog_synthetics" {
  count = local.enabled ? 1 : 0

  source  = "cloudposse/platform/datadog//modules/synthetics"
  version = "0.31.0"

  datadog_synthetics = local.synthetics_merged

  locations = [
    local.datadog_synthetics_private_location_id
  ]

  alert_tags           = var.alert_tags
  alert_tags_separator = var.alert_tags_separator

  context = module.this.context
}
