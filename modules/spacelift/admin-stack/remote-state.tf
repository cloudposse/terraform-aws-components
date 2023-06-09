module "spaces" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component   = "spacelift/spaces"
  environment = try(var.spacelift_spaces_environment_name, module.this.environment)
  stage       = try(var.spacelift_spaces_stage_name, module.this.stage)
  tenant      = try(var.spacelift_spaces_tenant_name, module.this.tenant)

  context = module.this.context
}
