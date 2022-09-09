locals {
  enabled     = module.this.enabled
  asm_enabled = var.secrets_store_type == "ASM"
  ssm_enabled = var.secrets_store_type == "SSM"

  # https://docs.datadoghq.com/account_management/api-app-keys/
  datadog_api_key = local.asm_enabled ? data.aws_secretsmanager_secret_version.datadog_api_key[0].secret_string : data.aws_ssm_parameter.datadog_api_key[0].value
  datadog_app_key = local.asm_enabled ? data.aws_secretsmanager_secret_version.datadog_app_key[0].secret_string : data.aws_ssm_parameter.datadog_app_key[0].value

  local_datadog_monitors_enabled  = length(var.local_datadog_monitors_config_paths) > 0
  remote_datadog_monitors_enabled = length(var.remote_datadog_monitors_config_paths) > 0
  datadog_monitors_enabled        = local.enabled && (local.remote_datadog_monitors_enabled || local.local_datadog_monitors_enabled)

  # Set the Datadog tenant and env tags using the context, unless specified by `var.datadog_monitors_config_parameters`
  dd_tenant = lookup(var.datadog_monitors_config_parameters, "dd_tenant", module.this.tenant)
  dd_env    = lookup(var.datadog_monitors_config_parameters, "dd_env", module.this.stage)
  datadog_monitors_config_parameters = merge(
    var.datadog_monitors_config_parameters,
    {
      "dd_tenant" : local.dd_tenant,
      "dd_env" : local.dd_env
    }
  )

  # Only return context tags that are specified
  context_tags = var.datadog_monitor_context_tags_enabled ? {
    for k, v in module.this.tags :
    lower(k) => v
    if contains(var.datadog_monitor_context_tags, lower(k))
  } : {}
  context_dd_tags = {
    context_dd_tags = join(",", [
      for k, v in local.context_tags :
      v != null ? format("%s:%s", k, v) : k
    ])
  }

  # For deep merge
  context_tags_in_tags = var.datadog_monitor_context_tags_enabled ? {
    tags = local.context_tags
  } : {}

  # Collect deep merged monitors
  datadog_monitors = {
    for k, v in module.datadog_monitors_merge :
    k => merge(v.merged, {
      message = format("%s%s%s", var.message_prefix, lookup(v.merged, "message", ""), var.message_postfix)
    })
  }

}

# Convert all Datadog Monitors from YAML config to Terraform map with token replacement using `parameters`
module "remote_datadog_monitors_yaml_config" {
  source  = "cloudposse/config/yaml"
  version = "1.0.1"

  map_config_remote_base_path = var.remote_datadog_monitors_base_path
  map_config_paths            = var.remote_datadog_monitors_config_paths

  parameters = merge(
    local.datadog_monitors_config_parameters,
    local.context_tags,
    local.context_dd_tags,
  )

  context = module.this.context
}

module "local_datadog_monitors_yaml_config" {
  source  = "cloudposse/config/yaml"
  version = "1.0.1"

  map_config_local_base_path = abspath(path.module)
  map_config_paths           = var.local_datadog_monitors_config_paths

  parameters = merge(
    local.datadog_monitors_config_parameters,
    local.context_tags,
    local.context_dd_tags,
  )

  context = module.this.context
}

module "datadog_monitors_merge" {
  source  = "cloudposse/config/yaml//modules/deepmerge"
  version = "1.0.1"

  # for_each = { for k, v in local.datadog_monitors_yaml_config_map_configs : k => v if local.datadog_monitors_enabled }
  for_each = { for k, v in merge(
    module.local_datadog_monitors_yaml_config.map_configs,
    module.remote_datadog_monitors_yaml_config.map_configs
  ) : k => v if local.datadog_monitors_enabled }

  # Merge in order: datadog monitor, datadog monitor globals, context tags
  maps = [
    each.value,
    var.datadog_monitor_globals,
    local.context_tags_in_tags,
  ]
}

module "datadog_monitors" {
  count = local.datadog_monitors_enabled ? 1 : 0

  source  = "cloudposse/platform/datadog//modules/monitors"
  version = "1.0.0"

  datadog_monitors = local.datadog_monitors

  alert_tags           = var.alert_tags
  alert_tags_separator = var.alert_tags_separator

  context = module.this.context
}
