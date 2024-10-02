locals {
  cluster_endpoint   = module.aurora_postgres.outputs.config_map.endpoint
  admin_user         = module.aurora_postgres.outputs.config_map.username
  admin_password_key = module.aurora_postgres.outputs.config_map.password_ssm_key

  admin_password = local.enabled ? (length(var.admin_password) > 0 ? var.admin_password : data.aws_ssm_parameter.admin_password[0].value) : ""
}

data "aws_ssm_parameter" "admin_password" {
  count = local.enabled && !(length(var.admin_password) > 0) ? 1 : 0

  name = local.admin_password_key

  with_decryption = true
}

provider "postgresql" {
  host      = local.cluster_endpoint
  username  = local.admin_user
  password  = local.admin_password
  superuser = false
}
