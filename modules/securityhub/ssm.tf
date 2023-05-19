data "aws_ssm_parameter" "opsgenie_integration_uri" {
  count = local.enabled && local.opsgenie_integration_enabled ? 1 : 0

  name            = format(var.opsgenie_integration_uri_key_pattern, var.opsgenie_integration_uri_key)
  with_decryption = true

  provider = aws.ssm
}
