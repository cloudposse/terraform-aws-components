variable "datadog_integration_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable Datadog integration with opsgenie (datadog side)"
}

data "aws_ssm_parameter" "opsgenie_team_api_key" {
  count           = local.enabled && var.datadog_integration_enabled ? 1 : 0
  name            = module.integration["datadog"].ssm_path
  with_decryption = true
  depends_on      = [module.integration]
}

resource "datadog_integration_opsgenie_service_object" "fake_service_name" {
  count            = local.enabled && var.datadog_integration_enabled ? 1 : 0
  name             = local.team_name
  opsgenie_api_key = data.aws_ssm_parameter.opsgenie_team_api_key[0].value
  region           = "us"
  depends_on       = [module.integration]
}



// Provider Configuration

provider "datadog" {
  api_key  = local.datadog_api_key
  app_key  = local.datadog_app_key
  validate = local.enabled
}

locals {
  asm_enabled = local.enabled && var.datadog_secrets_store_type == "ASM"
  ssm_enabled = local.enabled && var.datadog_secrets_store_type == "SSM"

  # https://docs.datadoghq.com/account_management/api-app-keys/
  datadog_api_key = local.enabled ? (local.asm_enabled ? data.aws_secretsmanager_secret_version.datadog_api_key[0].secret_string : data.aws_ssm_parameter.datadog_api_key[0].value) : null
  datadog_app_key = local.enabled ? (local.asm_enabled ? data.aws_secretsmanager_secret_version.datadog_app_key[0].secret_string : data.aws_ssm_parameter.datadog_app_key[0].value) : null
}

variable "datadog_secrets_store_type" {
  type        = string
  description = "Secret Store type for Datadog API and app keys. Valid values: `SSM`, `ASM`"
  default     = "SSM"
}

variable "datadog_api_secret_key" {
  type        = string
  description = "The key of the Datadog API secret"
  default     = "datadog/datadog_api_key"
}

variable "datadog_app_secret_key" {
  type        = string
  description = "The key of the Datadog Application secret"
  default     = "datadog/datadog_app_key"
}

// ASM

data "aws_secretsmanager_secret" "datadog_api_key" {
  count = local.asm_enabled ? 1 : 0
  name  = var.datadog_api_secret_key
}

data "aws_secretsmanager_secret_version" "datadog_api_key" {
  count     = local.asm_enabled ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.datadog_api_key[0].id
}

data "aws_secretsmanager_secret" "datadog_app_key" {
  count = local.asm_enabled ? 1 : 0
  name  = var.datadog_app_secret_key
}

data "aws_secretsmanager_secret_version" "datadog_app_key" {
  count     = local.asm_enabled ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.datadog_app_key[0].id
}


// SSM

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
