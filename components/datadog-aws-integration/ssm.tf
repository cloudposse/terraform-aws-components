data "aws_ssm_parameter" "datadog_api_key" {
  name            = format(var.ssm_parameter_name_format, var.ssm_path, "datadog_api_key")
  with_decryption = true
}

data "aws_ssm_parameter" "datadog_app_key" {
  name            = format(var.ssm_parameter_name_format, var.ssm_path, "datadog_app_key")
  with_decryption = true
}

resource "aws_ssm_parameter" "datadog_aws_iam_role_name" {
  name        = format(var.ssm_parameter_name_format, var.ssm_path, "datadog_aws_iam_role_name")
  description = "Name of the AWS IAM Role for Datadog to use for the integration"
  value       = module.datadog_integration.aws_role_name
  type        = "String"
}
