module "efs" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = var.efs_component_name

  context = module.this.context
}

module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = var.eks_component_name

  context = module.this.context
}
