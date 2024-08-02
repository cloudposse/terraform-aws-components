locals {
  kms_planner_enabled = contains(local.configured_policies, "kms_planner")
}

data "aws_iam_policy_document" "kms_planner_access" {
  count = local.kms_planner_enabled ? 1 : 0

  statement {
    sid    = "AllowKMSDecrypt"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
    ]

    # Only allow decryption of SSM parameters.
    # To further restrict to specific parameters, add conditions on the value of 
    #   kms:EncryptionContext:PARAMETER_ARN
    # See https://docs.aws.amazon.com/kms/latest/developerguide/services-parameter-store.html#parameter-store-encryption-context
    condition {
      test     = "Null"
      variable = "kms:EncryptionContext:PARAMETER_ARN"
      values   = ["false"]
    }

    resources = [
      "*"
    ]
  }

}

data "aws_iam_policy_document" "kms_planner_access_aggregated" {
  count = local.kms_planner_enabled ? 1 : 0

  source_policy_documents = [
    data.aws_iam_policy_document.kms_planner_access[0].json,
  ]
}

resource "aws_iam_policy" "kms_planner" {
  count = local.kms_planner_enabled ? 1 : 0

  name   = format("%s-kms_planner", module.this.id)
  policy = data.aws_iam_policy_document.kms_planner_access_aggregated[0].json

  tags = module.this.tags
}
