data "aws_ssm_parameter" "datadog_api_key" {
  count           = local.ssm_enabled ? 1 : 0
  name            = format("/%s", var.datadog_api_secret_key)
  with_decryption = true
}

data "aws_ssm_parameter" "datadog_app_key" {
  count           = local.ssm_enabled ? 1 : 0
  name            = format("/%s", var.datadog_app_secret_key)
  with_decryption = true
}
