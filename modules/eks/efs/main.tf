locals {
  enabled = module.this.enabled

  dns_name = format(var.hostname_template, var.tenant, var.stage, var.environment)

  eks_security_group_enabled = local.enabled && var.eks_security_group_enabled

  allowed_security_groups = [
    for eks in module.eks :
    eks.outputs.eks_cluster_managed_security_group_id
  ]

  private_subnet_ids = module.vpc.outputs.private_subnet_ids
  vpc_id             = module.vpc.outputs.vpc_id
  zone_id            = module.gbl_dns_delegated.outputs.default_dns_zone_id
}

module "efs" {
  source  = "cloudposse/efs/aws"
  version = "0.32.7"

  region                          = var.region
  vpc_id                          = local.vpc_id
  subnets                         = local.private_subnet_ids
  allowed_security_group_ids      = local.allowed_security_groups
  performance_mode                = var.performance_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  throughput_mode                 = var.throughput_mode
  dns_name                        = local.dns_name
  zone_id                         = [local.zone_id]
  encrypted                       = true
  kms_key_id                      = module.kms_key_efs.key_arn
  efs_backup_policy_enabled       = var.efs_backup_policy_enabled

  context = module.this.context
}

module "kms_key_efs" {
  source  = "cloudposse/kms-key/aws"
  version = "0.12.1"

  description             = "KMS key for EFS"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy                  = try(data.aws_iam_policy_document.kms_key_efs[0].json, "{}")

  context = module.this.context
}

data "aws_caller_identity" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_iam_policy_document" "kms_key_efs" {
  count = local.enabled ? 1 : 0

  # https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html#key-policy-default-allow-administrators
  # https://aws.amazon.com/premiumsupport/knowledge-center/update-key-policy-future/
  statement {
    sid    = "Enable the account that owns the KMS key to manage it via IAM"
    effect = "Allow"

    actions = [
      "kms:*"
    ]

    resources = [
      "*"
    ]

    principals {
      type = "AWS"

      identifiers = [
        format("arn:%s:iam::%s:root", join("", data.aws_partition.current.*.partition), join("", data.aws_caller_identity.current.*.account_id))
      ]
    }
  }

  # https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html
  # https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_principal.html
  # https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_aws-services-that-work-with-iam.html
  # https://docs.aws.amazon.com/efs/latest/ug/using-service-linked-roles.html
  statement {
    sid    = "Allow EFS to encrypt with the KMS key"
    effect = "Allow"

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    resources = [
      "*"
    ]

    principals {
      type = "Service"

      identifiers = [
        "elasticfilesystem.amazonaws.com"
      ]
    }
  }
}
