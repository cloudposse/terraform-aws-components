locals {
  enabled = module.this.enabled

  # Assume basic auth is enabled if the loki component has a basic auth username output
  basic_auth_enabled = local.enabled && length(module.loki.outputs.basic_auth_username) > 0
}

data "aws_ssm_parameter" "basic_auth_password" {
  provider = aws.source

  count = local.basic_auth_enabled ? 1 : 0

  name = module.loki.outputs.ssm_path_basic_auth_password
}

resource "grafana_data_source" "loki" {
  count = local.enabled ? 1 : 0

  type = "loki"
  name = module.loki.outputs.id
  uid  = module.loki.outputs.id
  url  = format("https://%s", module.loki.outputs.url)

  basic_auth_enabled  = local.basic_auth_enabled
  basic_auth_username = local.basic_auth_enabled ? module.loki.outputs.basic_auth_username : ""
  secure_json_data_encoded = jsonencode(local.basic_auth_enabled ? {
    basicAuthPassword = data.aws_ssm_parameter.basic_auth_password[0].value
  } : {})

  http_headers = {
    # https://grafana.com/docs/loki/latest/operations/authentication/
    # > When using Loki in multi-tenant mode, Loki requires the HTTP header
    # > X-Scope-OrgID to be set to a string identifying the tenant
    "X-Scope-OrgID" = "1"
  }
}
