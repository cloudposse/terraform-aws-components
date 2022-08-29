locals {
  enabled               = module.this.enabled
  mysql_enabled         = local.enabled && var.mysql_cluster_enabled
  ssm_passwords_enabled = local.enabled && var.ssm_passwords_enabled

  # If pulling passwords from SSM, determine the SSM path for passwords for each user
  # example SSM password source: /rds/acme-platform-use1-dev-rds-shared/%s/password
  ssm_path_prefix     = format("/%s/%s", var.ssm_path_prefix, module.aurora_mysql.outputs.aurora_mysql_cluster_id)
  ssm_password_source = length(var.ssm_password_source) > 0 ? var.ssm_password_source : format("%s/%s", local.ssm_path_prefix, "%s/password")

  password_users_to_fetch = local.ssm_passwords_enabled ? toset(concat(["admin"], keys(var.additional_grants))) : []

  mysql_admin_password = length(var.mysql_admin_password) > 0 ? var.mysql_admin_password : data.aws_ssm_parameter.password["admin"].value

  kms_key_arn = module.aurora_mysql.outputs.kms_key_arn
}

data "aws_ssm_parameter" "password" {
  for_each = local.password_users_to_fetch

  name = format(local.ssm_password_source, each.key)

  with_decryption = true
}

resource "mysql_database" "additional" {
  for_each = local.mysql_enabled ? var.additional_databases : []

  name = each.key
}

module "additional_users" {
  for_each = var.additional_users
  source   = "./modules/mysql-user"

  service_name    = each.key
  db_user         = each.value.db_user
  db_password     = each.value.db_password
  grants          = each.value.grants
  ssm_path_prefix = local.ssm_path_prefix
  kms_key_id      = local.kms_key_arn

  depends_on = [
    mysql_database.additional,
  ]

  context = module.this.context
}

module "additional_grants" {
  for_each = var.additional_grants
  source   = "./modules/mysql-user"

  service_name = each.key
  grants       = each.value
  kms_key_id   = local.kms_key_arn

  # If no password is given, a random password will be created
  db_password = local.ssm_passwords_enabled ? data.aws_ssm_parameter.password[each.key].value : ""
  # If generating a password, store it in SSM
  save_password_in_ssm = local.ssm_passwords_enabled ? false : true
  ssm_path_prefix      = local.ssm_path_prefix

  depends_on = [
    mysql_database.additional,
  ]

  context = module.this.context
}

