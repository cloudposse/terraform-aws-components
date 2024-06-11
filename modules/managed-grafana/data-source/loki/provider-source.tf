module "source_account_role" {
  source = "../../../account-map/modules/iam-roles"

  stage  = var.loki_stage_name
  tenant = var.loki_tenant_name

  context = module.this.context
}

provider "aws" {
  alias  = "source"
  region = var.region

  profile = module.source_account_role.terraform_profile_name

  dynamic "assume_role" {
    for_each = compact([module.source_account_role.terraform_role_arn])
    content {
      role_arn = assume_role.value
    }
  }
}
