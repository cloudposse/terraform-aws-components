# This is a special provider configuration that allows us to use many different
# versions of the Cloud Posse reference architecture to deploy this component
# in any account, including the identity and root accounts.

# If you have dynamic Terraform roles enabled and an `aws-team` (such as `managers`)
# empowered to make changes in the identity and root accounts. Then you can
# use those roles to deploy this component in the identity and root accounts,
# just like almost any other component.
#
# If you are restricted to using the SuperAdmin role to deploy this component
# in the identity and root accounts, then modify the stack configuration for
# this component for the identity and/or root accounts to set `superadmin: true`
# and backend `role_arn` to `null`.
#
#  components:
#    terraform:
#      github-oidc-provider:
#        backend:
#          s3:
#            role_arn: null
#        vars:
#          superadmin: true

provider "aws" {
  region = var.region

  profile = !var.superadmin && module.iam_roles.profiles_enabled ? module.iam_roles.terraform_profile_name : null
  dynamic "assume_role" {
    for_each = !var.superadmin && module.iam_roles.profiles_enabled ? [] : (
      var.superadmin ? compact([module.iam_roles.org_role_arn]) : compact([module.iam_roles.terraform_role_arn])
    )
    content {
      role_arn = assume_role.value
    }
  }
}


module "iam_roles" {
  source     = "../account-map/modules/iam-roles"
  privileged = var.superadmin

  context = module.this.context
}

variable "superadmin" {
  type        = bool
  default     = false
  description = "Set `true` if running as the SuperAdmin user"
}
