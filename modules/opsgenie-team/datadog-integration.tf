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
  depends_on       = [module.integration, module.datadog_configuration]
}
