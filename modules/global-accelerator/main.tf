locals {
  flow_logs_s3_bucket = try(length(var.flow_logs_s3_bucket), 0) > 0 ? var.flow_logs_s3_bucket : format("%v-%v-%v-global-accelerator-flow-logs", var.namespace, var.flow_logs_s3_bucket_environment, var.stage)
}

module "global_accelerator" {
  source  = "cloudposse/global-accelerator/aws"
  version = "0.4.0"

  context = module.this.context

  flow_logs_enabled   = var.flow_logs_enabled
  flow_logs_s3_prefix = var.flow_logs_s3_prefix
  flow_logs_s3_bucket = local.flow_logs_s3_bucket

  listeners = var.listeners
}
