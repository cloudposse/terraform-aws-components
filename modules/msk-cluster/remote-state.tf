module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.0"

  component = "vpc"

  context = module.this.context
}

module "vpc_ingress" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.0"

  for_each = toset(var.allow_ingress_from_vpc_stages)

  component = "vpc"
  tenant    = local.vpc_ingress_tenant_name
  stage     = each.key

  context = module.this.context
}

module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.0"

  component = "eks"

  bypass = !var.eks_security_group_ingress_enabled

  defaults = {
    eks_cluster_managed_security_group_id : ""
  }

  context = module.this.context
}

module "gbl_dns_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.0"

  component   = "dns-delegated"
  environment = "gbl"

  context = module.this.context
}
