module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.3.1"

  component = var.eks_component_name

  context = module.this.context
}
