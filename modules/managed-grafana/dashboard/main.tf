locals {
  enabled = module.this.enabled

  # Replace each of the keys in var.config_input with the given value in the module.config_json[0].merged result
  config_json = join("", [for k in keys(var.config_input) : replace(jsonencode(module.config_json[0].merged), k, var.config_input[k])])
}

data "http" "grafana_dashboard_json" {
  count = local.enabled ? 1 : 0

  url = var.dashboard_url
}

module "config_json" {
  source  = "cloudposse/config/yaml//modules/deepmerge"
  version = "1.0.2"

  count = local.enabled ? 1 : 0

  maps = [
    jsondecode(data.http.grafana_dashboard_json[0].response_body),
    {
      "title" : var.dashboard_name,
      "uid" : var.dashboard_name,
      "id" : var.dashboard_name
    },
    var.additional_config
  ]
}

resource "grafana_dashboard" "this" {
  count = local.enabled ? 1 : 0

  config_json = local.config_json
}
