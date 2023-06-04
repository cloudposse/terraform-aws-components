locals {
  # If you have custom policies, override this declaration by creating
  # a file called `additional-policy-map_override.tf`.
  # Then add the custom policies to the additional_custom_policy_map in that file.
  # See the README in `aws-team-roles` for more details.
  overridable_additional_custom_policy_map = {
    # Example:
    #   eks_viewer = aws_iam_policy.eks_viewer.arn
  }
}
