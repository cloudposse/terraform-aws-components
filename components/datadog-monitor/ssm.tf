data "aws_ssm_parameter" "datadog_api_key" {
  name            = format(var.ssm_parameter_name_format, var.ssm_path, "datadog_api_key")
  with_decryption = true
}

data "aws_ssm_parameter" "datadog_app_key" {
  name            = format(var.ssm_parameter_name_format, var.ssm_path, "datadog_app_key")
  with_decryption = true
}
