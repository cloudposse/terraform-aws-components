locals {
  datadog_api_key_name = (
    var.datadog_api_secret_key_target_pattern == replace(var.datadog_api_secret_key_target_pattern, "%v", "") ?
    var.datadog_api_secret_key_target_pattern : format(var.datadog_api_secret_key_target_pattern, var.datadog_api_secret_key)
  )

  datadog_app_key_name = (
    var.datadog_app_secret_key_target_pattern == replace(var.datadog_app_secret_key_target_pattern, "%v", "") ?
    var.datadog_app_secret_key_target_pattern : format(var.datadog_app_secret_key_target_pattern, var.datadog_api_secret_key)
  )
}

data "aws_ssm_parameter" "datadog_api_key" {
  count           = var.datadog_secrets_store_type == "SSM" ? 1 : 0
  name            = format(var.datadog_api_secret_key_source_pattern, var.datadog_api_secret_key)
  with_decryption = true

  provider = aws.api_keys
}

data "aws_ssm_parameter" "datadog_app_key" {
  count           = var.datadog_secrets_store_type == "SSM" ? 1 : 0
  name            = format(var.datadog_app_secret_key_source_pattern, var.datadog_app_secret_key)
  with_decryption = true
  provider        = aws.api_keys
}

module "store_write" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.10.0"

  parameter_write = [
    {
      name        = local.datadog_api_key_name
      value       = data.aws_ssm_parameter.datadog_api_key[0].value
      type        = "SecureString"
      overwrite   = "true"
      description = "Datadog API key"
    },
    {
      name        = local.datadog_app_key_name
      value       = data.aws_ssm_parameter.datadog_app_key[0].value
      type        = "SecureString"
      overwrite   = "true"
      description = "Datadog APP key"
    },
  ]

  context = module.this.context
}
