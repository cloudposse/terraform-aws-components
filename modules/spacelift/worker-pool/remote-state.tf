module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "account-map"
  environment = coalesce(var.account_map_environment_name, module.this.environment)
  stage       = var.account_map_stage_name
  tenant      = coalesce(var.account_map_tenant_name, module.this.tenant)

  context = module.this.context
}

module "ecr" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "ecr"
  environment = coalesce(var.ecr_environment_name, module.this.environment)
  stage       = var.ecr_stage_name
  tenant      = coalesce(var.ecr_tenant_name, module.this.tenant)

  context = module.this.context
}

module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = "vpc"

  context = module.this.context
}

module "spaces" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = var.spacelift_spaces_component_name
  environment = try(var.spacelift_spaces_environment_name, module.this.environment)
  stage       = try(var.spacelift_spaces_stage_name, module.this.stage)
  tenant      = try(var.spacelift_spaces_tenant_name, module.this.tenant)

  context = module.this.context
}
