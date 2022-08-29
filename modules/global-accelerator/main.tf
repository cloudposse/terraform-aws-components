locals {
  flow_logs_s3_bucket = var.flow_logs_enabled ? module.flow_logs_bucket[0].outputs.bucket_id : null
}

module "global_accelerator" {
  source  = "cloudposse/global-accelerator/aws"
  version = "0.5.0"

  flow_logs_enabled   = var.flow_logs_enabled
  flow_logs_s3_prefix = var.flow_logs_s3_prefix
  flow_logs_s3_bucket = local.flow_logs_s3_bucket

  listeners = var.listeners

  context = module.this.context
}
