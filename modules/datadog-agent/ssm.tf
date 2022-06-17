data "aws_ssm_parameter" "datadog_api_key" {
  count           = local.enabled && var.secrets_store_type == "SSM" ? 1 : 0
  name            = format("/%s", var.datadog_api_secret_key)
  with_decryption = true

  provider = aws.api_keys
}

data "aws_ssm_parameter" "datadog_app_key" {
  count           = local.enabled && var.secrets_store_type == "SSM" ? 1 : 0
  name            = format("/%s", var.datadog_app_secret_key)
  with_decryption = true

  provider = aws.api_keys
}
