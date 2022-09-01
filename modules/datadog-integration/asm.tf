data "aws_secretsmanager_secret" "datadog_api_key" {
  count = local.asm_enabled ? 1 : 0
  name  = format(var.datadog_api_secret_key_source_pattern, var.datadog_api_secret_key)

  provider = aws.api_keys
}

data "aws_secretsmanager_secret_version" "datadog_api_key" {
  count     = local.asm_enabled ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.datadog_api_key[0].id

  provider = aws.api_keys
}

data "aws_secretsmanager_secret" "datadog_app_key" {
  count = local.asm_enabled ? 1 : 0
  name  = format(var.datadog_app_secret_key_source_pattern, var.datadog_app_secret_key)

  provider = aws.api_keys
}

data "aws_secretsmanager_secret_version" "datadog_app_key" {
  count     = local.asm_enabled ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.datadog_app_key[0].id

  provider = aws.api_keys
}
