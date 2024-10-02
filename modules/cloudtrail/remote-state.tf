module "cloudtrail_bucket" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = var.cloudtrail_bucket_component_name
  environment = var.cloudtrail_bucket_environment_name
  stage       = var.cloudtrail_bucket_stage_name

  context = module.this.context
}

module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "account-map"
  tenant      = module.iam_roles.global_tenant_name
  environment = module.iam_roles.global_environment_name
  stage       = module.iam_roles.global_stage_name

  context = module.this.context
}
