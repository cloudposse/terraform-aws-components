locals {
  enabled = module.this.enabled

  db_user     = length(var.db_user) > 0 ? var.db_user : var.service_name
  db_password = length(var.db_password) > 0 ? var.db_password : join("", random_password.db_password.*.result)

  create_db_user       = local.enabled && var.service_name != local.db_user
  save_password_in_ssm = local.enabled && var.save_password_in_ssm

  db_user_key     = format("%s/%s/users/%s/username", var.ssm_path_prefix, var.service_name, local.db_user)
  db_password_key = format("%s/%s/users/%s/password", var.ssm_path_prefix, var.service_name, local.db_user)

  db_user_ssm = local.create_db_user ? {
    name        = local.db_user_key
    value       = local.db_user
    description = "MySQL Username for ${var.service_name} service"
    type        = "String"
    overwrite   = true
  } : null
  db_password_ssm = local.save_password_in_ssm ? {
    name        = local.db_password_key
    value       = local.db_password
    description = "MySQL Password for DB user ${local.db_user}"
    type        = "SecureString"
    overwrite   = true
  } : null

  # In order to avoid:
  # "local.parameter_write will be known only after apply"
  # We must define exactly what the list should include
  parameter_write = (local.create_db_user && local.save_password_in_ssm) ? [local.db_user_ssm, local.db_password_ssm] : (((local.create_db_user) ? [local.db_user_ssm] : ((local.save_password_in_ssm) ? [local.db_password_ssm] : [])))

  # You cannot grant "ALL" to an RDS user because "ALL" includes privileges that
  # Master does not have (because this is a managed database).
  # See the full list of available options at https://docs.amazonaws.cn/en_us/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Security.html
  # This is all the privileges an application should need.
  # Privileges not listed are not available.
  # Privileges commented out are dangerous or cannot be limited to 1 database and should not be needed by an app
  all_rds_app_grants = [
    "ALTER",
    "ALTER ROUTINE",
    "CREATE",
    "CREATE ROUTINE",
    "CREATE TEMPORARY TABLES",
    # "CREATE USER",
    "CREATE VIEW",
    "DELETE",
    "DROP",
    "EVENT",
    "EXECUTE",
    # "GRANT OPTION",
    "INDEX",
    "INSERT",
    "LOAD FROM S3",
    "LOCK TABLES",
    # "PROCESS",
    "REFERENCES",
    # "RELOAD",
    # "REPLICATION CLIENT",
    # "REPLICATION SLAVE",
    "SELECT",
    # "SHOW DATABASES",
    "SHOW VIEW",
    "TRIGGER",
    "UPDATE"
  ]
  all_rds_other_grants = [
    "CREATE USER",
    "GRANT OPTION",
    "PROCESS",
    "RELOAD",
    "REPLICATION CLIENT",
    "REPLICATION SLAVE",
    "SHOW DATABASES",
  ]
  all_grants = distinct(concat(local.all_rds_app_grants, local.all_rds_other_grants))
}

resource "random_password" "db_password" {
  count   = local.enabled && length(var.db_password) == 0 ? 1 : 0
  length  = 33
  special = false

  keepers = {
    db_user = local.db_user
  }
}

resource "mysql_user" "default" {
  count              = local.enabled ? 1 : 0
  user               = local.db_user
  host               = "%"
  plaintext_password = local.db_password
}

# Grant the user full access to this specific database
resource "mysql_grant" "default" {
  count    = local.enabled ? length(var.grants) : 0
  user     = join("", mysql_user.default.*.user)
  host     = join("", mysql_user.default.*.host)
  database = split(".", var.grants[count.index].db)[0]
  # We would like to use
  # table = try(split(".", var.grants[count.index].db)[1], "*")
  # but when we create the database, no tables exist, and we cannot
  # limit a grant to a non-existent table.
  table = "*"

  privileges = flatten([for grant in var.grants[count.index].grant : (
    grant == "ALL_APP" ? local.all_rds_app_grants : grant == "ALL" ? local.all_grants : [grant]
  )])

  depends_on = [mysql_user.default]
  # Apparently this is needed. See https://github.com/terraform-providers/terraform-provider-mysql/issues/55#issuecomment-615463296
  lifecycle {
    create_before_destroy = true
  }
}

module "parameter_store_write" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.10.0"

  # kms_arn will only be used for SecureString parameters
  kms_arn = var.kms_key_id # not necessarily ARN — alias works too

  parameter_write = local.parameter_write

  context = module.this.context
}
