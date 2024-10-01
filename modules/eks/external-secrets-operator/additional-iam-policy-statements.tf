locals {
  # If you have custom policy statements, override this declaration by creating
  # a file called `additional-iam-policy-statements_override.tf`.
  # Then add the custom policy statements to the overridable_additional_iam_policy_statements in that file.
  overridable_additional_iam_policy_statements = [
    #  {
    #    sid    = "UseKMS"
    #    effect = "Allow"
    #    actions = [
    #      "kms:Decrypt"
    #    ]
    #    resources = [
    #      "*"
    #    ]
    #  }
  ]
}
