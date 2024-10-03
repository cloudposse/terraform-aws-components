module "flow_logs_bucket" {
  count = var.flow_logs_enabled ? 1 : 0

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = var.flow_logs_s3_bucket_component
  tenant      = var.flow_logs_s3_bucket_tenant
  stage       = var.flow_logs_s3_bucket_stage
  environment = var.flow_logs_s3_bucket_environment

  context = module.this.context
}
