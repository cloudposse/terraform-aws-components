module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  component = var.eks_component_name

  context = module.this.context
}
