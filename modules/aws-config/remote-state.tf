module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "account-map"
  tenant      = (var.account_map_tenant != "") ? var.account_map_tenant : module.this.tenant
  stage       = var.root_account_stage
  environment = var.global_environment
  privileged  = var.privileged

  context = module.this.context
}

module "config_bucket" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "config-bucket"
  tenant      = (var.config_bucket_tenant != "") ? var.config_bucket_tenant : module.this.tenant
  stage       = var.config_bucket_stage
  environment = var.config_bucket_env
  privileged  = false

  context = module.this.context
}

module "global_collector_region" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  count = !local.enabled || local.is_global_collector_region ? 0 : 1

  component   = "aws-config-${lookup(module.utils.region_az_alt_code_maps["to_${var.az_abbreviation_type}"], var.global_resource_collector_region)}"
  stage       = module.this.stage
  environment = lookup(module.utils.region_az_alt_code_maps["to_${var.az_abbreviation_type}"], var.global_resource_collector_region)
  privileged  = false

  context = module.this.context
}

module "aws_team_roles" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "aws-team-roles"
  environment = var.iam_roles_environment_name

  context = module.this.context
}
