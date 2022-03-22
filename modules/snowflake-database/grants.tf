resource "snowflake_database_grant" "grant" {
  for_each = toset(local.database_grants)

  database_name = snowflake_database.this[0].name

  privilege = each.key
  roles     = [local.snowflake_terraform_role]

  with_grant_option = true
}

resource "snowflake_schema_grant" "grant" {
  for_each = toset(local.schema_grants)

  database_name = snowflake_database.this[0].name

  privilege = each.key
  roles     = [local.snowflake_terraform_role]

  on_future         = true
  with_grant_option = true
}

resource "snowflake_table_grant" "grant" {
  for_each = toset(local.table_grants)

  database_name = snowflake_schema.this[0].database
  schema_name   = snowflake_schema.this[0].name

  privilege = each.key
  roles     = [local.snowflake_terraform_role]

  on_future         = true
  with_grant_option = true
}

resource "snowflake_view_grant" "grant" {
  for_each = toset(local.view_grants)

  database_name = snowflake_schema.this[0].database
  schema_name   = snowflake_schema.this[0].name

  privilege = each.key
  roles     = [local.snowflake_terraform_role]

  on_future         = true
  with_grant_option = true
}
