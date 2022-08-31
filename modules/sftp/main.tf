locals {
  enabled = module.this.enabled

  default_global_s3_bucket_name_key = "module_default"

  # Retrieve all s3 bucket contexts from each user and the global context
  s3_bucket_contexts = merge(
    {
      for user, val in var.sftp_users :
      user => lookup(val, "s3_bucket_context", var.s3_bucket_context)
      # if lookup(val, "s3_bucket_context", null) != null && lookup(val, "s3_bucket_context", {}) != {}
    },
    {
      (local.default_global_s3_bucket_name_key) = var.s3_bucket_context
    },
  )

  # Insert the fully qualified s3 bucket name for each user
  sftp_users = {
    for user, val in var.sftp_users :
    user => merge(
      val,
      lookup(module.s3_context, user, null) != null ? {
        s3_bucket_name = lookup(module.s3_context, user).id
      } : {},
      # This has to be added otherwise terraform may throw an error if the user object is different
      {
        s3_bucket_context = {}
      },
    )
  }
}

module "s3_context" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  for_each = local.s3_bucket_contexts

  delimiter   = lookup(each.value, "delimiter", null)
  name        = lookup(each.value, "name", null)
  environment = lookup(each.value, "environment", null)
  tenant      = lookup(each.value, "tenant", null)
  stage       = lookup(each.value, "stage", null)
  attributes  = lookup(each.value, "attributes", [])

  # empty attributes
  context = merge(module.this.context, {
    attributes = [],
  })
}

data "aws_s3_bucket" "default" {
  for_each = local.enabled ? local.s3_bucket_contexts : {}

  bucket = module.s3_context[each.key].id
}

module "security_group" {
  source  = "cloudposse/security-group/aws"
  version = "1.0.1"

  vpc_id = module.vpc.outputs.vpc_id
  rules  = var.security_group_rules

  context = module.this.context
}

data "aws_route53_zone" "default" {
  count = local.enabled ? 1 : 0

  name = "${var.stage}.${var.hosted_zone_suffix}"
}

module "sftp" {
  source  = "cloudposse/transfer-sftp/aws"
  version = "1.2.0"

  domain                 = var.domain
  sftp_users             = local.sftp_users
  s3_bucket_name         = data.aws_s3_bucket.default[local.default_global_s3_bucket_name_key].id
  restricted_home        = var.restricted_home
  force_destroy          = var.force_destroy
  address_allocation_ids = var.address_allocation_ids
  security_policy_name   = var.security_policy_name
  domain_name            = var.domain_name
  zone_id                = one(data.aws_route53_zone.default[*].id)
  eip_enabled            = var.eip_enabled

  vpc_security_group_ids = concat(
    [
      module.vpc.outputs.vpc_default_security_group_id,
      module.security_group.id,
    ],
    var.vpc_security_group_ids
  )

  # if endpoint type is VPC instead of public
  # vpc_id                 = module.vpc.outputs.vpc_id
  # subnet_ids             = module.vpc.outputs.private_subnet_ids
  # vpc_security_group_ids = concat([module.vpc.outputs.vpc_default_security_group_id], var.vpc_security_group_ids)
  # vpc_endpoint_id        = var.vpc_endpoint_id

  context = module.this.context
}
