locals {
  database_name = module.glue_catalog_database.outputs.catalog_database_name
}

module "glue_catalog_table" {
  source  = "cloudposse/glue/aws//modules/glue-catalog-table"
  version = "0.4.0"

  catalog_table_name        = var.catalog_table_name
  catalog_table_description = var.catalog_table_description
  catalog_id                = var.catalog_id
  database_name             = local.database_name
  owner                     = var.owner
  parameters                = var.parameters
  partition_index           = var.partition_index
  partition_keys            = var.partition_keys
  retention                 = var.retention
  table_type                = var.table_type
  target_table              = var.target_table
  view_expanded_text        = var.view_expanded_text
  view_original_text        = var.view_original_text
  storage_descriptor        = var.storage_descriptor

  context = module.this.context
}

# Grant Lake Formation permissions to the Glue IAM role that is used to access the Glue table.
# This prevents the error:
# Error: error creating Glue crawler: InvalidInputException: Insufficient Lake Formation permission(s) on <table>> (Service: AmazonDataCatalog; Status Code: 400; Error Code: AccessDeniedException
# https://aws.amazon.com/premiumsupport/knowledge-center/glue-insufficient-lakeformation-permissions
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lakeformation_permissions
resource "aws_lakeformation_permissions" "default" {
  count = module.this.enabled && var.lakeformation_permissions_enabled ? 1 : 0

  principal   = module.glue_iam_role.outputs.role_arn
  permissions = var.lakeformation_permissions

  table {
    database_name = local.database_name
    name          = module.glue_catalog_table.name
  }
}
