provider "aws" {
  alias  = "tgw-hub"
  region = var.region

  # Profile is deprecated in favor of terraform_role_arn. When profiles are not in use, terraform_profile_name is null.
  profile = module.tgw_hub_role.terraform_profile_name

  dynamic "assume_role" {
    # module.tgw_hub_role.terraform_role_arn may be null, in which case do not assume a role.
    for_each = compact([module.tgw_hub_role.terraform_role_arn])
    content {
      role_arn = assume_role.value
    }
  }
}

module "tgw_hub_role" {
  source = "../../account-map/modules/iam-roles"

  stage  = var.tgw_hub_stage_name
  tenant = var.tgw_hub_tenant_name

  context = module.this.context
}
