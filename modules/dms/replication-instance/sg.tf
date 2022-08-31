locals {
  ingress_cidr_blocks_enabled = var.security_group_ingress_cidr_blocks != null && length(var.security_group_ingress_cidr_blocks) > 0

  rules = local.ingress_cidr_blocks_enabled ? [
    {
      type        = "ingress"
      from_port   = var.security_group_ingress_from_port
      to_port     = var.security_group_ingress_to_port
      protocol    = "all"
      cidr_blocks = var.security_group_ingress_cidr_blocks
    }
  ] : []
}

module "security_group" {
  source  = "cloudposse/security-group/aws"
  version = "1.0.1"

  vpc_id                = module.vpc.outputs.vpc_id
  create_before_destroy = var.security_group_create_before_destroy
  allow_all_egress      = var.security_group_allow_all_egress
  rules                 = local.rules

  context = module.this.context
}
