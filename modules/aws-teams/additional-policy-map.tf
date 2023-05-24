locals {
  # If you have custom policies, delete this file and add
  #      - "**/additional-policy-map.tf"
  # to `excluded_paths` in component.yaml

  # Then add the custom policies to the additional_custom_policy_map in another file.
  additional_custom_policy_map = {
    # Example:
    #   eks_viewer        = try(aws_iam_policy.eks_viewer[0].arn, null)
  }
}
