data "aws_ssm_parameter" "endpoint" {
  count = local.enabled && var.ssm_path_endpoint != null ? 1 : 0

  name = var.ssm_path_endpoint
}

data "aws_ssm_parameter" "user" {
  count = local.enabled && var.ssm_path_username != null ? 1 : 0

  name = var.ssm_path_username
}

data "aws_ssm_parameter" "password" {
  count = local.enabled && var.ssm_path_password != null ? 1 : 0

  name = var.ssm_path_password
}
