module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.0"

  component = "vpc"

  context = module.cluster.context
}

module "vpc_spacelift" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.0"

  component = "vpc"
  stage     = var.vpc_spacelift_stage_name

  context = module.cluster.context
}

module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.0"

  component = "eks"

  context = module.cluster.context
}

module "dns_gbl_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.0"

  component   = "dns-delegated"
  environment = var.dns_gbl_delegated_environment_name

  context = module.cluster.context
}
