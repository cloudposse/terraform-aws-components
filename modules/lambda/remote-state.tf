module "s3_bucket" {
  count = local.enabled && var.s3_bucket_component != null ? 1 : 0

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.s3_bucket_component.component

  tenant      = var.s3_bucket_component.tenant
  environment = var.s3_bucket_component.environment
  stage       = var.s3_bucket_component.stage

  context = module.this.context
}
