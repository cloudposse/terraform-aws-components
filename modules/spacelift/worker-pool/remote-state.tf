module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component   = "account-map"
  environment = coalesce(var.account_map_environment_name, module.this.environment)
  stage       = var.account_map_stage_name
  tenant      = coalesce(var.account_map_tenant_name, module.this.tenant)

  context = module.this.context
}

module "ecr" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component   = "ecr"
  environment = coalesce(var.ecr_environment_name, module.this.environment)
  stage       = var.ecr_stage_name
  tenant      = coalesce(var.ecr_tenant_name, module.this.tenant)

  context = module.this.context
}

module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = "vpc"

  context = module.this.context
}
