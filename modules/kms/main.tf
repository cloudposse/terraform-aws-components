locals {
  account_id        = data.aws_caller_identity.current.account_id
  account_principal = "arn:${data.aws_partition.current.partition}:iam::${local.account_id}:root"

  principals = sort(distinct(concat(
    var.allowed_principal_arns,
    module.allowed_role_map.principals,
  )))
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

module "allowed_role_map" {
  source = "../account-map/modules/roles-to-principals"

  privileged = false
  role_map   = var.allowed_roles

  context = module.this.context
}

module "kms_key" {
  source  = "cloudposse/kms-key/aws"
  version = "0.12.2"

  alias                    = var.alias == null ? "alias/${module.this.id}" : var.alias
  description              = var.description == null ? "${module.this.id} KMS Key. Managed by Terraform." : var.description
  deletion_window_in_days  = var.deletion_window_in_days
  enable_key_rotation      = var.enable_key_rotation
  key_usage                = var.key_usage
  customer_master_key_spec = var.customer_master_key_spec
  multi_region             = var.multi_region

  policy = var.policy != "" ? var.policy : data.aws_iam_policy_document.key_policy.json

  context = module.this.context
}

data "aws_iam_policy_document" "key_policy" {

  statement {
    sid    = "KeyAdministration"
    effect = "Allow"

    actions = [
      "kms:*",
    ]

    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [local.account_principal]
    }
  }

  statement {
    sid    = "KeyUsage"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = local.principals
    }
  }
}
