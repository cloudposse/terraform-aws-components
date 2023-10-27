locals {
  failover_enabled = local.enabled && try(length(var.failover_s3_origin_environment), 0) > 0
  failover_region  = local.failover_enabled ? module.utils.region_az_alt_code_maps.from_fixed[var.failover_s3_origin_environment] : var.region
  failover_bucket  = local.failover_enabled ? format(var.failover_s3_origin_format, var.namespace, var.failover_s3_origin_environment, var.stage, var.name) : null
}

module "utils" {
  source  = "cloudposse/utils/aws"
  version = "1.3.0"
}

data "aws_s3_bucket" "failover_bucket" {
  count = local.failover_enabled ? 1 : 0

  bucket = local.failover_bucket

  provider = aws.failover
}
