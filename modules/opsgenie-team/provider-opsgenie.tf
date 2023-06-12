data "aws_ssm_parameter" "opsgenie_api_key" {
  name            = format(var.ssm_parameter_name_format, var.ssm_path, "opsgenie_api_key")
  with_decryption = true
}

provider "opsgenie" {
  api_key = join("", data.aws_ssm_parameter.opsgenie_api_key[*].value)
}
