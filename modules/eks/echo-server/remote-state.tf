module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.3"

  component = var.eks_component_name

  context = module.this.context
}

module "alb" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.3"

  component = var.alb_controller_ingress_group_component_name

  context = module.this.context
}
