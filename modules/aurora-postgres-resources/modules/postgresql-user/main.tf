locals {
  enabled = module.this.enabled

  db_user     = length(var.db_user) > 0 ? var.db_user : var.service_name
  db_password = length(var.db_password) > 0 ? var.db_password : join("", random_password.db_password.*.result)

  save_password_in_ssm = local.enabled && var.save_password_in_ssm

  db_password_key = format("%s/%s/passwords/%s", var.ssm_path_prefix, var.service_name, local.db_user)
  db_password_ssm = local.save_password_in_ssm ? {
    name        = local.db_password_key
    value       = local.db_password
    description = "Postgres Password for DB user ${local.db_user}"
    type        = "SecureString"
    overwrite   = true
  } : null

  parameter_write = local.save_password_in_ssm ? [local.db_password_ssm] : []

  # ALL grant always shows Terraform drift:
  # https://github.com/cyrilgdn/terraform-provider-postgresql/issues/32
  # To workaround, expand what an ALL grant means for db or table
  # https://github.com/cyrilgdn/terraform-provider-postgresql/blob/master/postgresql/helpers.go#L237-L244
  all_privileges_database = ["CREATE", "CONNECT", "TEMPORARY"]
  all_privileges_schema   = ["CREATE", "USAGE"]
}

resource "random_password" "db_password" {
  count   = local.enabled && length(var.db_password) == 0 ? 1 : 0
  length  = 33
  special = false

  keepers = {
    db_user = local.db_user
  }
}

resource "postgresql_role" "default" {
  count    = local.enabled ? 1 : 0
  name     = local.db_user
  password = local.db_password
  login    = true
}

# Apply the configured grants to the user
resource "postgresql_grant" "default" {
  count       = local.enabled ? length(var.grants) : 0
  role        = join("", postgresql_role.default.*.name)
  database    = var.grants[count.index].db
  schema      = var.grants[count.index].schema
  object_type = var.grants[count.index].object_type

  # Conditionally set the privileges to either the explicit list of database privileges
  # or schema privileges if this is a db grant or a schema grant respectively.
  # We can determine this is a schema grant if a schema is given
  privileges = contains(var.grants[count.index].grant, "ALL") ? ((length(var.grants[count.index].schema) > 0) ? local.all_privileges_schema : local.all_privileges_database) : var.grants[count.index].grant
}

module "parameter_store_write" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.10.0"

  # kms_arn will only be used for SecureString parameters
  kms_arn = var.kms_key_id # not necessarily ARN — alias works too

  parameter_write = local.parameter_write

  context = module.this.context
}
