locals {
  # If you have custom addons, create a file called `additional-addon-support_override.tf`
  # and in that file override any of the following declarations as needed.


  # Set `overridable_deploy_additional_addons_to_fargate` to indicate whether or not
  # there are custom addons that should be deployed to Fargate on nodeless clusters.
  overridable_deploy_additional_addons_to_fargate = false

  # `overridable_additional_addon_service_account_role_arn_map` is a map of addon names
  # to the service account role ARNs they use.
  # See the README for more details.
  overridable_additional_addon_service_account_role_arn_map = {
    # Example:
    # my-addon = module.my_addon_eks_iam_role.service_account_role_arn
  }

  # If you are creating Fargate profiles for your addons,
  # use "cloudposse/eks-fargate-profile/aws" to create them
  # and set `overridable_additional_addon_fargate_profiles` to a map of addon names
  # to the corresponding eks-fargate-profile module output.
  overridable_additional_addon_fargate_profiles = {
    # Example:
    # my-addon = module.my_addon_fargate_profile
  }

  # If you have additional dependencies that must be created before the addons are deployed,
  # override this declaration by creating a file called `additional-addon-support_override.tf`
  # and setting `overridable_addons_depends_on` appropriately.
  overridable_addons_depends_on = []
}
