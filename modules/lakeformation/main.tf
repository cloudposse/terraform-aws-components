# Find our service-linked role for Lake Formation if we weren't provided a role
# and we're not attempting to create it...
data "aws_iam_role" "lakeformation" {
  count = (var.role_arn == null && !var.create_service_linked_role) ? 1 : 0

  name = "AWSServiceRoleForLakeFormationDataAccess"
}

resource "aws_iam_service_linked_role" "lakeformation" {
  count = var.create_service_linked_role ? 1 : 0

  aws_service_name = "lakeformation.amazonaws.com"
}

locals {
  role_arn = coalesce(var.role_arn, try(aws_iam_service_linked_role.lakeformation[0].arn, null), try(data.aws_iam_role.lakeformation[0].arn, null))

  # We need the Terraform role to have admin rights in order to complete the deployment
  admin_arn_list = concat([module.iam_roles.terraform_role_arn], var.admin_arn_list)
}

module "lakeformation" {
  source  = "cloudposse/lakeformation/aws"
  version = "0.1.0"

  enabled = module.this.enabled

  s3_bucket_arn                = var.s3_bucket_arn
  role_arn                     = local.role_arn
  catalog_id                   = var.catalog_id
  admin_arn_list               = local.admin_arn_list
  trusted_resource_owners      = var.trusted_resource_owners
  database_default_permissions = var.database_default_permissions
  table_default_permissions    = var.table_default_permissions
  lf_tags                      = var.lf_tags

  resources = var.resources

  context = module.this.context
}
