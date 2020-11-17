# Convert all Datadog monitors from YAML config to Terraform map
module "datadog_monitors_yaml_config" {
  source = "git::https://github.com/cloudposse/terraform-yaml-config.git?ref=tags/0.1.0"

  map_config_local_base_path = path.module
  map_config_paths           = var.datadog_monitors_config_paths

  context = module.this.context
}

module "datadog_monitors" {
  source = "git::https://github.com/cloudposse/terraform-datadog-monitor.git?ref=tags/0.9.0"

  datadog_monitors     = module.datadog_monitors_yaml_config.map_configs
  alert_tags           = var.alert_tags
  alert_tags_separator = var.alert_tags_separator

  context = module.this.context
}
