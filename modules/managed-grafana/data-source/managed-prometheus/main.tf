locals {
  enabled = module.this.enabled
}

resource "grafana_data_source" "managed_prometheus" {
  count = local.enabled ? 1 : 0

  type = "prometheus"
  name = module.prometheus.outputs.id
  uid  = module.prometheus.outputs.id
  url  = module.prometheus.outputs.workspace_endpoint

  json_data_encoded = jsonencode({
    sigV4Auth          = true
    httpMethod         = "POST"
    sigV4AuthType      = "ec2_iam_role"
    sigV4AssumeRoleArn = module.prometheus.outputs.access_role_arn
    sigV4Region        = module.prometheus.outputs.workspace_region
  })
}
