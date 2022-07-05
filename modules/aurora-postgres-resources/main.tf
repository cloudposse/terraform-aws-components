locals {
  enabled = module.this.enabled

  cluster_endpoint             = try(module.aurora_postgres.outputs.primary_aurora_postgres_master_endpoint, module.aurora_postgres.outputs.endpoint)
  cluster_name                 = try(module.aurora_postgres.outputs.primary_aurora_postgres_cluster_identifier, null)
  database_name                = try(module.aurora_postgres.outputs.aurora_postgres_database_name, module.aurora_postgres.outputs.database_name)
  admin_user                   = try(module.aurora_postgres.outputs.aurora_postgres_admin_username, module.aurora_postgres.outputs.admin_username)
  ssm_path_prefix              = try(module.aurora_postgres.outputs.aurora_postgres_ssm_path_prefix, module.aurora_postgres.outputs.ssm_cluster_key_prefix)
  admin_password_ssm_parameter = try(module.aurora_postgres.outputs.aurora_postgres_master_password_ssm_key, module.aurora_postgres.outputs.config_map.password_ssm_key)
  admin_password               = join("", data.aws_ssm_parameter.admin_password[*].value)
}

data "aws_ssm_parameter" "admin_password" {
  count = local.enabled ? 1 : 0

  name            = local.admin_password_ssm_parameter
  with_decryption = true
}
