# module.iam_roles_datadog_secrets.terraform_profile_name
provider "aws" {
  alias  = "api_keys"
  region = coalesce(var.datadog_secrets_source_store_account_region, var.region)

  # Profile is deprecated in favor of terraform_role_arn. When profiles are not in use, terraform_profile_name is null.
  profile = module.iam_roles_datadog_secrets.terraform_profile_name

  dynamic "assume_role" {
    # module.iam_roles_datadog_secrets.terraform_role_arn may be null, in which case do not assume a role.
    for_each = compact([module.iam_roles_datadog_secrets.terraform_role_arn])
    content {
      role_arn = assume_role.value
    }
  }
}

module "iam_roles_datadog_secrets" {
  source  = "../account-map/modules/iam-roles"
  stage   = var.datadog_secrets_source_store_account_stage
  tenant  = var.datadog_secrets_source_store_account_tenant
  context = module.this.context
}
