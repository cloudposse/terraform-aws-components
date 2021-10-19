data "aws_ssm_parameter" "github_token" {
  count = local.enabled ? 1 : 0

  name            = format(var.ssm_parameter_name_format, var.ssm_path, "token")
  with_decryption = true
}
