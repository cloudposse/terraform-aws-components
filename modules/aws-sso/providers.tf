# This is a special provider configuration that allows us to use many different
# versions of the Cloud Posse reference architecture to deploy this component
# in any account, including the identity and root accounts.

# If you have dynamic Terraform roles enabled and an `aws-team` (such as `managers`)
# empowered to make changes in the identity and root accounts. Then you can
# use those roles to deploy this component in the identity and root accounts,
# just like almost any other component. Leave `privileged: false` and leave the
# backend `role_arn` at its default value.
#
# For those not using dynamic Terraform roles:
#
# If you are deploying this to the "identity" account and are restricted to using
# the SuperAdmin role to deploy components to "identity", then you will need to
# set the stack configuration for this component to set `privileged: true`
# and backend `role_arn` to `null`.
#
# If you are deploying this to the "identity" account and have a team empowered
# to deploy components to "identity", then you will need to set the stack
# configuration for this component to set `privileged: false` and leave the
# backend `role_arn` at its default value.
#
# If you are deploying this to the "root" account, then you will need to
# set the stack configuration for this component to set `privileged: true`
# and backend `role_arn` to `null`, and deploy it using either the SuperAdmin
# role or any other role in the `root` account with Admin access.

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


module "iam_roles_root" {
  source = "../account-map/modules/iam-roles"

  privileged  = var.privileged
  tenant      = module.iam_roles.global_tenant_name
  stage       = module.iam_roles.global_stage_name
  environment = module.iam_roles.global_environment_name

  context = module.this.context
}
