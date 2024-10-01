locals {
  enabled = module.this.enabled

  ssm_path_api_key = format(var.ssm_path_format_api_key, module.this.id)
}

resource "time_rotating" "ttl" {
  rotation_minutes = var.minutes_to_live
}

resource "time_static" "ttl" {
  rfc3339 = time_rotating.ttl.rfc3339
}

resource "aws_grafana_workspace_api_key" "key" {
  count = local.enabled ? 1 : 0

  key_name        = module.this.id
  key_role        = var.key_role
  seconds_to_live = var.minutes_to_live * 60
  workspace_id    = module.managed_grafana.outputs.workspace_id

  lifecycle {
    replace_triggered_by = [
      time_static.ttl
    ]
  }
}

module "ssm_parameters" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.13.0"

  parameter_write = [
    {
      name        = local.ssm_path_api_key
      value       = aws_grafana_workspace_api_key.key[0].key
      type        = "SecureString"
      overwrite   = "true"
      description = "Grafana Workspace API Key"
    }
  ]

  context = module.this.context
}
