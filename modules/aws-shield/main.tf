locals {
  enabled = module.this.enabled
  tags    = module.this.tags

  account_id = one(data.aws_caller_identity.current[*].account_id)

  # Used to determine correct partition (i.e. - `aws`, `aws-gov`, `aws-cn`, etc.)
  partition = one(data.aws_partition.current[*].partition)

  alb_protection_enabled                     = local.enabled && length(var.alb_names) > 0
  cloudfront_distribution_protection_enabled = local.enabled && length(var.cloudfront_distribution_ids) > 0
  eip_protection_enabled                     = local.enabled && length(var.eips) > 0
  route53_protection_enabled                 = local.enabled && length(var.route53_zone_names) > 0
}

data "aws_caller_identity" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}
