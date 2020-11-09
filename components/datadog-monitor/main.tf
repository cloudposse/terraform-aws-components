locals {
  datadog_monitors = merge([
    for monitors_file in fileset(path.module, "monitors/*.yaml") : {
      for k, v in yamldecode(file(format("%s/%s", path.module, monitors_file))) : k => v
    }
  ]...)
}

module "datadog_monitors" {
  source = "git::https://github.com/cloudposse/terraform-datadog-monitor.git?ref=tags/0.8.0"

  datadog_monitors     = local.datadog_monitors
  alert_tags           = var.alert_tags
  alert_tags_separator = var.alert_tags_separator

  context = module.this.context
}
