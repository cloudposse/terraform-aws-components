variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
}

variable "alb_controller_ingress_group_component_name" {
  type        = string
  description = "The name of the eks/alb-controller-ingress-group component. This should be an internal facing ALB"
  default     = "eks/alb-controller-ingress-group"
}

module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.eks_component_name

  context = module.this.context
}

module "alb_controller_ingress_group" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.alb_controller_ingress_group_component_name

  context = module.this.context
}

module "dns_gbl_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  environment = "gbl"
  component   = "dns-delegated"

  context = module.this.context
}
