locals {
  # If you have custom policies, override this declaration by creating
  # a file called `additional-policy-map_override.tf`.
  # Then add the custom policies to the overridable_additional_custom_policy_map in that file.
  # The key should be the policy you want to override, the value is the json policy document.
  # See the README in `github-oidc-role` for more details.
  overridable_additional_custom_policy_map = {
    # Example:
    #   gitops = aws_iam_policy.my_custom_gitops_policy.policy
  }
}
