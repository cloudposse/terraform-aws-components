module "dns-delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  component   = "dns-delegated"
  environment = "gbl"

  context = module.this.context
}

module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  for_each = var.eks_component_names

  component = each.value

  context = module.this.context
}

module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  component = "vpc"

  context = module.this.context
}

module "primary_cluster" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  count = local.remote_read_replica_enabled ? 1 : 0

  component   = var.primary_cluster_component
  environment = var.primary_cluster_region

  context = module.this.context
}
