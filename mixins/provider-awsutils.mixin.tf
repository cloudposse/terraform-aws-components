# <-- BEGIN DOC -->
#
# This mixin is meant to be added to a terraform module that wants to use the awsutils provider.
# It assumes the standard `providers.tf` file is present in the module.
#
# <-- END DOC -->

provider "awsutils" {
  region = var.region

  # Profile is deprecated in favor of terraform_role_arn. When profiles are not in use, terraform_profile_name is null.
  profile = module.iam_roles.terraform_profile_name

  dynamic "assume_role" {
    # module.iam_roles.terraform_role_arn may be null, in which case do not assume a role.
    for_each = compact([module.iam_roles.terraform_role_arn])
    content {
      role_arn = module.iam_roles.terraform_role_arn
    }
  }
}
