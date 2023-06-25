provider "aws" {
  alias  = "config_secrets"
  region = var.ssm_store_account_region

  # Profile is deprecated in favor of terraform_role_arn. When profiles are not in use, terraform_profile_name is null.
  profile = module.iam_roles_config_secrets.terraform_profile_name

  dynamic "assume_role" {
    # module.iam_roles.terraform_role_arn may be null, in which case do not assume a role.
    for_each = compact([module.iam_roles_config_secrets.terraform_role_arn])
    content {
      role_arn = assume_role.value
    }
  }
}

module "iam_roles_config_secrets" {
  source  = "../../account-map/modules/iam-roles"
  stage   = var.ssm_store_account
  tenant  = var.ssm_store_account_tenant
  context = module.this.context
}
