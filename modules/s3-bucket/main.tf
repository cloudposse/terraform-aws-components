locals {
  enabled = module.this.enabled

  aws_partition = data.aws_partition.current.partition

  custom_policy_account_arns = [
    for acct in var.custom_policy_account_names :
    format("arn:%s:iam::%s:root", local.aws_partition, module.account_map.outputs.full_account_map[acct])
  ]

  bucket_policy = var.custom_policy_enabled ? data.aws_iam_policy_document.custom_policy[0].json : data.template_file.bucket_policy.rendered
}

data "aws_partition" "current" {}

data "template_file" "bucket_policy" {
  template = module.bucket_policy.json

  vars = {
    id = module.this.id
  }
}

module "bucket_policy" {
  source  = "cloudposse/iam-policy/aws"
  version = "0.3.0"

  iam_policy_statements = var.source_policy_documents

  context = module.introspection.context
}

module "s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "2.0.0"

  bucket_name = var.bucket_name

  # Object access and permissions
  acl                          = var.acl
  grants                       = var.grants
  allow_encrypted_uploads_only = var.allow_encrypted_uploads_only
  allow_ssl_requests_only      = var.allow_ssl_requests_only
  block_public_acls            = var.block_public_acls
  block_public_policy          = var.block_public_policy
  ignore_public_acls           = var.ignore_public_acls
  restrict_public_buckets      = var.restrict_public_buckets
  logging                      = var.logging
  source_policy_documents      = [local.bucket_policy]
  privileged_principal_actions = var.privileged_principal_actions
  privileged_principal_arns    = var.privileged_principal_arns

  # Static website configuration
  cors_rule_inputs = var.cors_rule_inputs
  website_inputs   = var.website_inputs

  # Bucket feature flags
  transfer_acceleration_enabled = var.transfer_acceleration_enabled
  versioning_enabled            = var.versioning_enabled
  force_destroy                 = var.force_destroy
  object_lock_configuration     = var.object_lock_configuration

  # Object lifecycle rules
  lifecycle_configuration_rules = var.lifecycle_configuration_rules

  # Object encryption
  sse_algorithm      = var.sse_algorithm
  kms_master_key_arn = var.kms_master_key_arn

  # Object replication
  s3_replication_enabled      = var.s3_replication_enabled
  s3_replica_bucket_arn       = var.s3_replica_bucket_arn
  s3_replication_rules        = var.s3_replication_rules
  s3_replication_source_roles = var.s3_replication_source_roles

  # IAM user with permissions to access the s3 bucket
  user_enabled           = var.user_enabled
  allowed_bucket_actions = var.allowed_bucket_actions

  context = module.introspection.context
}

data "aws_iam_policy_document" "custom_policy" {
  count = local.enabled && var.custom_policy_enabled ? 1 : 0

  statement {
    actions = var.custom_policy_actions

    resources = [
      format("arn:%s:s3:::%s", local.aws_partition, module.this.id),
      format("arn:%s:s3:::%s/*", local.aws_partition, module.this.id)
    ]
    principals {
      identifiers = length(local.custom_policy_account_arns) > 0 ? local.custom_policy_account_arns : ["*"]
      type        = "AWS"
    }

    effect = "Allow"
  }
}
