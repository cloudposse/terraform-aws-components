locals {
  database_name = module.glue_catalog_database.outputs.catalog_database_name
  table_name    = module.glue_catalog_table.outputs.catalog_table_name
  iam_role_arn  = module.glue_iam_role.outputs.role_arn

  catalog_target = var.catalog_target != null ? var.catalog_target : [
    {
      database_name = local.database_name
      tables        = [local.table_name]
    }
  ]
}

module "glue_crawler" {
  source  = "cloudposse/glue/aws//modules/glue-crawler"
  version = "0.4.0"

  crawler_name           = var.crawler_name
  crawler_description    = var.crawler_description
  database_name          = local.database_name
  role                   = local.iam_role_arn
  schedule               = var.schedule
  classifiers            = var.classifiers
  configuration          = var.configuration
  jdbc_target            = var.jdbc_target
  dynamodb_target        = var.dynamodb_target
  s3_target              = var.s3_target
  mongodb_target         = var.mongodb_target
  catalog_target         = local.catalog_target
  delta_target           = var.delta_target
  table_prefix           = var.table_prefix
  security_configuration = var.security_configuration
  schema_change_policy   = var.schema_change_policy
  lineage_configuration  = var.lineage_configuration
  recrawl_policy         = var.recrawl_policy

  context = module.this.context
}
