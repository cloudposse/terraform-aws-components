module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "account-map"
  environment = try(coalesce(var.account_map_environment_name, module.this.environment), null)
  stage       = var.account_map_stage_name
  tenant      = try(coalesce(var.account_map_tenant_name, module.this.tenant), null)

  context = module.this.context
}

module "ecr" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "ecr"
  environment = try(coalesce(var.ecr_environment_name, module.this.environment), null)
  stage       = var.ecr_stage_name
  tenant      = try(coalesce(var.ecr_tenant_name, module.this.tenant), null)

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
  environment = try(coalesce(var.spacelift_spaces_environment_name, module.this.environment), null)
  stage       = try(coalesce(var.spacelift_spaces_stage_name, module.this.stage), null)
  tenant      = try(coalesce(var.spacelift_spaces_tenant_name, module.this.tenant), null)

  context = module.this.context
}
