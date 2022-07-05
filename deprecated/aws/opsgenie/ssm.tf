data "aws_ssm_parameter" "opsgenie_api_key" {
  name            = format(var.ssm_parameter_name_format, var.ssm_path, "opsgenie_api_key")
  with_decryption = true
}

# There currently does not exist a resource within the Datadog provider that will
# allow us to provision the Opsgenie integration, so we'll write our integration key
# to SSM and handle this piece manually.
# https://docs.datadoghq.com/integrations/opsgenie/
resource "aws_ssm_parameter" "opsgenie_datadog_api_key" {
  name        = format(var.ssm_parameter_name_format, var.ssm_path, "opsgenie_datadog_api_key")
  description = "Opsgenie Datadog API key for Datadog integration"
  value       = module.opsgenie_config.api_integration_keys["datadog"]
  type        = "SecureString"
  key_id      = var.kms_key_arn
}
