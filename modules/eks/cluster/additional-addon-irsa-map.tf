locals {
  # If you have custom addons that require EKS IAM Roles for Kubernetes Service Accounts,
  # override this declaration by creating a file called `additional-addon-irsa-map_override.tf`.
  # Then add the custom map of addon names to the service account role ARNs to the `overridable_additional_addon_service_account_role_arn_map` in that file.
  # See the README for more details.
  overridable_additional_addon_service_account_role_arn_map = {
    # Example:
    # my-addon = module.my_addon_eks_iam_role.service_account_role_arn
  }
}
