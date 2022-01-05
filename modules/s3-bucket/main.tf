locals {
  enabled = module.this.enabled

  custom_policy_account_arns = [
    for acct in var.custom_policy_account_names :
    format("arn:%s:iam::%s:root", data.aws_partition.current.partition, module.account_map.outputs.full_account_map[acct])
  ]

  bucket_policy = var.custom_policy_enabled ? data.aws_iam_policy_document.custom_policy[0].json : var.policy
}

data "aws_partition" "current" {}

module "s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "0.44.2"

  abort_incomplete_multipart_upload_days = var.abort_incomplete_multipart_upload_days
  acl                                    = var.acl
  allow_encrypted_uploads_only           = var.allow_encrypted_uploads_only
  allow_ssl_requests_only                = var.allow_ssl_requests_only
  block_public_acls                      = var.block_public_acls
  block_public_policy                    = var.block_public_policy
  bucket_name                            = var.bucket_name
  cors_rule_inputs                       = var.cors_rule_inputs
  force_destroy                          = var.force_destroy
  grants                                 = var.grants
  ignore_public_acls                     = var.ignore_public_acls
  kms_master_key_arn                     = var.kms_master_key_arn
  lifecycle_rules                        = var.lifecycle_rules
  logging                                = var.logging
  object_lock_configuration              = var.object_lock_configuration
  policy                                 = local.bucket_policy
  privileged_principal_actions           = var.privileged_principal_actions
  privileged_principal_arns              = var.privileged_principal_arns
  restrict_public_buckets                = var.restrict_public_buckets
  s3_replica_bucket_arn                  = var.s3_replica_bucket_arn
  s3_replication_enabled                 = var.s3_replication_enabled
  s3_replication_rules                   = var.s3_replication_rules
  s3_replication_source_roles            = var.s3_replication_source_roles
  sse_algorithm                          = var.sse_algorithm
  transfer_acceleration_enabled          = var.transfer_acceleration_enabled
  versioning_enabled                     = var.versioning_enabled
  website_inputs                         = var.website_inputs

  # IAM user with permissions to access the s3 bucket
  user_enabled           = var.user_enabled
  allowed_bucket_actions = var.allowed_bucket_actions

  context = module.this.context
}

data "aws_iam_policy_document" "custom_policy" {
  count = local.enabled && var.custom_policy_enabled ? 1 : 0

  statement {
    actions = var.custom_policy_actions

    resources = [
      format("arn:aws:s3:::%s-%s-%s-%s", module.this.namespace, module.this.environment, module.this.stage, module.this.name),
      format("arn:aws:s3:::%s-%s-%s-%s/*", module.this.namespace, module.this.environment, module.this.stage, module.this.name)
    ]
    principals {
      identifiers = local.custom_policy_account_arns
      type        = "AWS"
    }

    effect = "Allow"
  }
}
