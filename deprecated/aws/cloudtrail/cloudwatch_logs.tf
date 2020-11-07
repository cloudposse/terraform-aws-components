module "logs" {
  source     = "git::https://github.com/cloudposse/terraform-aws-cloudwatch-logs.git?ref=tags/0.3.0"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  attributes = ["cloudwatch", "logs"]

  retention_in_days = "${var.cloudwatch_logs_retention_in_days}"

  principals = {
    Service = ["cloudtrail.amazonaws.com"]
  }

  additional_permissions = [
    "logs:CreateLogStream",
  ]
}

module "kms_key_logs" {
  source     = "git::https://github.com/cloudposse/terraform-aws-kms-key.git?ref=tags/0.1.3"
  namespace  = "${var.namespace}"
  name       = "${var.name}"
  stage      = "${var.stage}"
  attributes = ["cloudwatch", "logs"]

  description             = "KMS key for CloudWatch"
  deletion_window_in_days = 10
  enable_key_rotation     = "true"

  policy = "${data.aws_iam_policy_document.kms_key_logs.json}"
}

data "aws_iam_policy_document" "kms_key_logs" {
  statement {
    sid    = "Allow CloudWatch to Encrypt with the key"
    effect = "Allow"

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]

    resources = [
      "*",
    ]

    principals {
      type = "Service"

      identifiers = [
        "logs.${local.region}.amazonaws.com",
      ]
    }
  }
}
