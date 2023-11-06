module "alb" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = "eks/alb-controller-ingress-group"

  context = module.this.context
}
