module "alb" {
  count   = local.alb_protection_enabled == false ? 0 : length(var.alb_names) > 0 ? 0 : 1
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = "eks/alb-controller-ingress-group"

  context = module.this.context
}
