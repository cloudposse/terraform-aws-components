module "sso" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.0"

  component   = "sso"
  environment = var.sso_environment_name
  stage       = var.sso_stage_name
  privileged  = true

  context = module.this.context
}

module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.0"

  component   = "account-map"
  environment = var.account_map_environment_name
  stage       = var.account_map_stage_name
  privileged  = true

  context = module.this.context
}

module "spacelift_worker_pool" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.0"

  count = var.spacelift_roles_enabled ? 1 : 0

  component   = "spacelift-worker-pool"
  environment = coalesce(var.spacelift_worker_pool_environment_name, module.this.environment)
  stage       = var.spacelift_worker_pool_stage_name

  context = module.this.context
}

