provider "aws" {
  region = var.region

  profile = !var.privileged && module.iam_roles.profiles_enabled ? module.iam_roles.terraform_profile_name : null
  dynamic "assume_role" {
    for_each = var.privileged || module.iam_roles.profiles_enabled || (module.iam_roles.terraform_role_arn == null) ? [] : ["role"]
    content {
      role_arn = module.iam_roles.terraform_role_arn
    }
  }
}

module "iam_roles" {
  source     = "../account-map/modules/iam-roles"
  privileged = var.privileged

  context = module.this.context
}
