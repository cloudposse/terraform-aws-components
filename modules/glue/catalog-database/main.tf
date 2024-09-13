module "glue_catalog_database" {
  source  = "cloudposse/glue/aws//modules/glue-catalog-database"
  version = "0.4.0"

  catalog_database_name           = var.catalog_database_name
  catalog_database_description    = var.catalog_database_description
  catalog_id                      = var.catalog_id
  create_table_default_permission = var.create_table_default_permission
  location_uri                    = var.location_uri
  parameters                      = var.parameters
  target_database                 = var.target_database

  context = module.this.context
}

# Grant Lake Formation permissions to the Glue IAM role that is used to access the Glue database.
# This prevents the error:
# Error: error creating Glue crawler: InvalidInputException: Insufficient Lake Formation permission(s) on <database>> (Service: AmazonDataCatalog; Status Code: 400; Error Code: AccessDeniedException
# https://aws.amazon.com/premiumsupport/knowledge-center/glue-insufficient-lakeformation-permissions
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lakeformation_permissions
resource "aws_lakeformation_permissions" "default" {
  count = module.this.enabled && var.lakeformation_permissions_enabled ? 1 : 0

  principal   = module.glue_iam_role.outputs.role_arn
  permissions = var.lakeformation_permissions

  database {
    name = module.glue_catalog_database.name
  }
}
