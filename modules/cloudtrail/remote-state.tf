module "cloudtrail_bucket" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component   = var.cloudtrail_bucket_component_name
  environment = var.cloudtrail_bucket_environment_name
  stage       = var.cloudtrail_bucket_stage_name

  context = module.this.context
}
