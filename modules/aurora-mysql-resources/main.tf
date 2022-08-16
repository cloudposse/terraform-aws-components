locals {
  enabled       = module.this.enabled
  mysql_enabled = var.mysql_cluster_enabled && local.enabled

  fetch_passwords         = local.enabled && length(var.ssm_password_source) > 0
  password_users_to_fetch = local.fetch_passwords ? toset(concat([local.mysql_admin_user], keys(var.additional_grants))) : []

  mysql_admin_user     = module.aurora_mysql.outputs.aurora_mysql_master_username
  mysql_admin_password = local.fetch_passwords ? data.aws_ssm_parameter.password[local.mysql_admin_user].value : var.mysql_admin_password

  kms_key_arn = module.aurora_mysql.outputs.kms_key_arn
}

data "aws_ssm_parameter" "password" {
  for_each = local.password_users_to_fetch

  name = format(var.ssm_password_source, each.key)

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
  ssm_path_prefix = var.ssm_path_prefix
  kms_key_id      = local.kms_key_arn

  depends_on = [
    mysql_database.additional,
  ]

  context = module.this.context
}

module "additional_grants" {
  for_each = var.additional_grants
  source   = "./modules/mysql-user"

  service_name    = each.key
  db_password     = local.fetch_passwords ? data.aws_ssm_parameter.password[each.key].value : ""
  grants          = each.value
  ssm_path_prefix = var.ssm_path_prefix
  # There is a difference in how Terraform formats the "not" (`!`) operator
  # between Terraform version 0.13 and 0.14 so we avoid using it to
  # avoid formatting wars.
  save_password_in_ssm = local.fetch_passwords ? false : true
  kms_key_id           = local.kms_key_arn

  depends_on = [
    mysql_database.additional,
  ]

  context = module.this.context
}

