locals {
  enabled                  = module.introspection.enabled
  snowflake_account_region = module.snowflake_account.outputs.snowflake_region
  snowflake_account        = module.snowflake_account.outputs.snowflake_account
  snowflake_terraform_role = module.snowflake_account.outputs.snowflake_terraform_role

  tables = local.enabled ? var.tables : {}
  views  = local.enabled ? var.views : {}

  database_grants = local.enabled ? var.database_grants : []
  schema_grants   = local.enabled ? var.schema_grants : []
  table_grants    = local.enabled ? var.table_grants : []
  view_grants     = local.enabled ? var.view_grants : []
}

module "utils" {
  source  = "cloudposse/utils/aws"
  version = "0.8.1"
  context = module.introspection.context
}

# Create a standard label to define resource name for Snowflake best practice.
module "snowflake_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  environment      = lookup(module.utils.region_az_alt_code_maps["to_short"], local.snowflake_account_region)
  delimiter        = "_"
  label_value_case = "upper"

  context = module.introspection.context
}

module "snowflake_database" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = ["db"]
  context    = module.snowflake_label.context
}

resource "snowflake_database" "this" {
  count = local.enabled ? 1 : 0

  name                        = module.snowflake_database.id
  comment                     = var.database_comment
  data_retention_time_in_days = var.data_retention_time_in_days
}

module "snowflake_schema" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = ["schema"]
  context    = module.snowflake_label.context
}

resource "snowflake_schema" "this" {
  count = local.enabled ? 1 : 0

  database = snowflake_database.this[0].name
  name     = module.snowflake_schema.id

  depends_on = [
    snowflake_schema_grant.grant
  ]
}

module "snowflake_sequence" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = ["sequence"]
  context    = module.snowflake_label.context
}

resource "snowflake_sequence" "this" {
  count = local.enabled ? 1 : 0

  database = snowflake_schema.this[0].database
  schema   = snowflake_schema.this[0].name
  name     = module.snowflake_sequence.id
}

resource "snowflake_table" "tables" {
  for_each = local.tables

  database            = snowflake_schema.this[0].database
  schema              = snowflake_schema.this[0].name
  data_retention_days = snowflake_schema.this[0].data_retention_days

  name    = each.key
  comment = each.value.comment

  column {
    name     = "id"
    type     = "int"
    nullable = true

    default {
      sequence = snowflake_sequence.this[0].fully_qualified_name
    }
  }

  dynamic "column" {
    for_each = each.value.columns
    content {
      name = column.value["name"]
      type = column.value["type"]
    }
  }

  primary_key {
    name = each.value.primary_key.name
    keys = each.value.primary_key.keys
  }

  depends_on = [
    snowflake_table_grant.grant
  ]

  # Ignore changes to column type because of a known issue with the provider.
  # Terraform will show changes on plan for updating the type, even though there are not any changes.
  # https://github.com/chanzuckerberg/terraform-provider-snowflake/issues/494
  #
  # Furthermore, Terraform doesn't support wildcards or variables in the lifecycle block, so either we can ignore all changes to `column` or need to list out all indices manually.
  # """
  # A single static variable reference is required: only attribute access and indexing with constant keys.
  # No calculations, function calls, template expressions, etc are allowed here.
  # """
  # https://github.com/hashicorp/terraform/issues/5666
  lifecycle {
    ignore_changes = [
      column[0].type,
      column[1].type,
      column[2].type,
      column[3].type,
      column[4].type,
      column[5].type,
      column[6].type,
      column[7].type,
      column[8].type,
      column[9].type,
      column[10].type,
    ]
  }
}

resource "snowflake_view" "view" {
  for_each = local.views

  database = snowflake_schema.this[0].database
  schema   = snowflake_schema.this[0].name

  name    = each.key
  comment = each.value.comment

  statement = each.value.statement

  or_replace = false
  is_secure  = false

  depends_on = [
    snowflake_view_grant.grant,
    snowflake_table.tables
  ]
}
