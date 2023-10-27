# This component is unusual in that part of it must be deployed to the `root`
# account. You have the option of where to deploy the remaining part, and
# Cloud Posse recommends you deploy it also to the `root` account, however
# it can be deployed to the `identity` account instead. In the discussion
# below, when we talk about where this module is being deployed, we are
# referring to the part of the module that is not deployed to the `root`
# account and is configured by setting `stage` etc..

# If you have Dynamic Terraform Roles enabled, leave the backend `role_arn` at
# its default value. If deploying only to the `root` account, leave `privileged: false`
# and use either SuperAdmin or an appropriate `aws-team` (such as `managers`).
# If deploying to the `identity` account, set `privileged: true`
# and use SuperAdmin or any other role in the `root` account with Admin access.
#
# For those not using dynamic Terraform roles:
#
# Set the stack configuration for this component to set `privileged: true`
# and backend `role_arn` to `null`, and deploy it using either the SuperAdmin
# role or any other role in the `root` account with Admin access.
#
# If you are deploying this to the "identity" account and have a team empowered
# to deploy to both the "identity" and "root" accounts, then you have the option to set
# `privileged: false` and leave the backend `role_arn` at its default value, but
# then SuperAdmin will not be able to deploy this component,
# only the team with access to both accounts will be able to deploy it.
#

provider "aws" {
  region = var.region

  profile = !var.privileged && module.iam_roles.profiles_enabled ? module.iam_roles.terraform_profile_name : null
  dynamic "assume_role" {
    for_each = !var.privileged && module.iam_roles.profiles_enabled ? [] : (
      var.privileged ? compact([module.iam_roles.org_role_arn]) : compact([module.iam_roles.terraform_role_arn])
    )
    content {
      role_arn = assume_role.value
    }
  }
}


module "iam_roles" {
  source     = "../account-map/modules/iam-roles"
  privileged = var.privileged

  context = module.this.context
}

provider "aws" {
  alias  = "root"
  region = var.region

  profile = !var.privileged && module.iam_roles_root.profiles_enabled ? module.iam_roles_root.terraform_profile_name : null
  dynamic "assume_role" {
    for_each = !var.privileged && module.iam_roles_root.profiles_enabled ? [] : (
      var.privileged ? compact([module.iam_roles_root.org_role_arn]) : compact([module.iam_roles_root.terraform_role_arn])
    )
    content {
      role_arn = assume_role.value
    }
  }
}


module "iam_roles_root" {
  source = "../account-map/modules/iam-roles"

  privileged  = var.privileged
  tenant      = module.iam_roles.global_tenant_name
  stage       = module.iam_roles.global_stage_name
  environment = module.iam_roles.global_environment_name

  context = module.this.context
}
