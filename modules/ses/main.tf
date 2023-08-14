locals {
  enabled     = module.this.enabled
  ses_domain  = format(var.domain_template, var.tenant, var.environment, var.stage)
  ses_zone_id = module.dns_gbl_delegated.outputs.default_dns_zone_id

  aws_partition = data.aws_partition.current.partition
  account_id    = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

module "ses" {
  source  = "cloudposse/ses/aws"
  version = "0.22.3"

  domain        = local.ses_domain
  zone_id       = local.ses_zone_id
  verify_dkim   = var.ses_verify_dkim
  verify_domain = var.ses_verify_domain

  context = module.this.context
}

module "kms_key_ses" {
  source  = "cloudposse/kms-key/aws"
  version = "0.12.1"

  description             = "KMS key for SES"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy                  = join("", data.aws_iam_policy_document.kms_key_ses.*.json)

  context = module.this.context
}

module "ssm_parameter_store" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.11.0"

  count = local.enabled ? 1 : 0

  # KMS key is only applied to SecureString params
  # https://github.com/cloudposse/terraform-aws-ssm-parameter-store/blob/master/main.tf#L17
  kms_arn = module.kms_key_ses.key_arn

  parameter_write = [
    {
      description = "SES AWS access key ID"
      name        = "/ses/ses_access_key_id"
      overwrite   = true
      type        = "String"
      value       = module.ses.access_key_id
    },
    {
      description = "SES user IAM secret for usage with SES API"
      name        = "/ses/ses_secret_access_key"
      overwrite   = true
      type        = "SecureString"
      value       = module.ses.secret_access_key
    },
    {
      description = "SES IAM user name"
      name        = "/ses/ses_user_name"
      overwrite   = true
      type        = "String"
      value       = module.ses.user_name
    },
    {
      description = "SES SMTP password"
      name        = "/ses/ses_smtp_password"
      overwrite   = true
      type        = "SecureString"
      value       = module.ses.ses_smtp_password
    }
  ]

  context = module.this.context
}

data "aws_iam_policy_document" "kms_key_ses" {
  #bridgecrew:skip=BC_AWS_IAM_57: Skipping `Write access allowed without constraint` check. This is a resource-based policy allowing the account to use the CMK.
  #bridgecrew:skip=BC_AWS_IAM_56: Skipping `Resource exposure allows modification of policies and exposes resources` check. See note above.
  count = local.enabled ? 1 : 0

  # https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html#key-policy-default-allow-administrators
  # https://aws.amazon.com/premiumsupport/knowledge-center/update-key-policy-future/
  statement {
    sid    = "Allow the account identity to manage the KMS key"
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
        format("arn:%s:iam::%s:root", local.aws_partition, local.account_id)
      ]
    }
  }

  statement {
    sid    = "Allow SES to encrypt with the KMS key"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:GenerateDataKey*"
    ]

    resources = [
      "*"
    ]

    principals {
      type = "Service"

      identifiers = [
        "ses.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:EncryptionContext:aws:ses:source-account"

      values = [
        local.account_id
      ]
    }
  }
}
