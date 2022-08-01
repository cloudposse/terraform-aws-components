# So we can assign admin permissions to the current user
data "aws_caller_identity" "current" {}

locals {
  admin_arn_list = concat(data.aws_caller_identity.current.arn, var.admin_arn_list)
}

module "lakeformation" {
  source  = "cloudposse/lakeformation/aws"
  version = "0.1.0"

  enabled = module.this.enabled

  s3_bucket_arn                = var.s3_bucket_arn
  role_arn                     = var.role_arn
  catalog_id                   = var.catalog_id
  admin_arn_list               = local.admin_arn_list
  trusted_resource_owners      = var.trusted_resource_owners
  database_default_permissions = var.database_default_permissions
  table_default_permissions    = var.table_default_permissions
  lf_tags                      = var.lf_tags

  resources = var.resources

  context = module.this.context
}
