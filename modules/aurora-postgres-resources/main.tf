locals {
  enabled = module.this.enabled

  # If pulling passwords from SSM, determine the SSM path for passwords for each user
  # example SSM password source: /rds/acme-platform-use1-dev-rds-shared/%s/password
  read_passwords_from_ssm = local.enabled && var.read_passwords_from_ssm
  password_users_to_fetch = local.read_passwords_from_ssm ? toset(keys(var.additional_grants)) : []
  ssm_path_prefix         = format("/%s/%s", var.ssm_path_prefix, module.aurora_postgres.outputs.cluster_identifier)
  ssm_password_source     = length(var.ssm_password_source) > 0 ? var.ssm_password_source : format("%s/%s", local.ssm_path_prefix, "%s/password")

  kms_key_arn = module.aurora_postgres.outputs.kms_key_arn

  default_schema_owner = "postgres"
}

data "aws_ssm_parameter" "password" {
  for_each = local.password_users_to_fetch

  name = format(local.ssm_password_source, each.key)

  with_decryption = true
}

resource "postgresql_database" "additional" {
  for_each = local.enabled ? var.additional_databases : []

  name = each.key
}

resource "postgresql_schema" "additional" {
  for_each = local.enabled ? var.additional_schemas : {}

  name     = each.key
  database = try(each.value.database, null) # If null, the database used by your provider configuration
}

module "additional_users" {
  for_each = local.enabled ? var.additional_users : {}
  source   = "./modules/postgresql-user"

  service_name    = each.key
  db_user         = each.value.db_user
  db_password     = each.value.db_password
  grants          = each.value.grants
  ssm_path_prefix = local.ssm_path_prefix
  kms_key_id      = local.kms_key_arn

  depends_on = [
    postgresql_database.additional,
    postgresql_schema.additional,
  ]

  context = module.this.context
}

module "additional_grants" {
  for_each = var.additional_grants
  source   = "./modules/postgresql-user"

  service_name = each.key
  grants       = each.value
  kms_key_id   = local.kms_key_arn

  # If `read_passwords_from_ssm` is true, that means passwords already exist in SSM
  # If no password is given, a random password will be created
  db_password = local.read_passwords_from_ssm ? data.aws_ssm_parameter.password[each.key].value : ""
  # If generating a password, store it in SSM. Otherwise, we don't need to save an existing password in SSM
  save_password_in_ssm = local.read_passwords_from_ssm ? false : true
  ssm_path_prefix      = local.ssm_path_prefix

  depends_on = [
    postgresql_database.additional,
    postgresql_schema.additional,
  ]

  context = module.this.context
}
