locals {
  account_id                              = join("", data.aws_caller_identity.current.*.account_id)
  aws_partition                           = join("", data.aws_partition.current.*.partition)
  autoscaling_service_linked_role_enabled = local.enabled && var.autoscaling_service_linked_role_enabled
  autoscaling_service_linked_role_default = format("arn:%s:iam::%s:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", local.aws_partition, local.account_id)
  autoscaling_service_linked_role_arn     = local.autoscaling_service_linked_role_enabled ? join("", aws_iam_service_linked_role.autoscaling.*.id) : local.autoscaling_service_linked_role_default
}

resource "aws_iam_service_linked_role" "autoscaling" {
  count = local.autoscaling_service_linked_role_enabled ? 1 : 0

  aws_service_name = "autoscaling.amazonaws.com"
}

data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_caller_identity" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_iam_policy_document" "eks_kms_key" {
  count = local.enabled ? 1 : 0

  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        format("arn:%s:iam::%s:root", local.aws_partition, local.account_id)
      ]
    }
  }

  statement {
    sid       = "Allow service-linked role use of the customer managed key"
    effect    = "Allow"
    actions   = ["kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [local.autoscaling_service_linked_role_arn]
    }
  }

  statement {
    sid       = "Allow attachment of persistent resources"
    effect    = "Allow"
    actions   = ["kms:CreateGrant"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [local.autoscaling_service_linked_role_arn]
    }

    condition {
      test     = "Bool"
      values   = [true]
      variable = "kms:GrantIsForAWSResource"
    }
  }
}

module "kms_key_eks" {
  source  = "cloudposse/kms-key/aws"
  version = "0.12.1"

  description             = "KMS key for EKS"
  deletion_window_in_days = 10
  enabled                 = local.enabled
  enable_key_rotation     = true
  policy                  = try(data.aws_iam_policy_document.eks_kms_key[0].json, "{}")

  context = module.this.context
}
