locals {
  vpcs               = var.tgw_config.vpcs
  own_vpc            = local.vpcs[var.owning_account].outputs
  own_eks_sg         = var.tgw_config.eks[var.owning_account].outputs.eks_cluster_managed_security_group_id
  connected_accounts = [for acct in var.tgw_config.connected_accounts[var.owning_account] : acct if acct != var.owning_account]

  allowed_cidrs = [
    for k, v in local.vpcs : v.outputs.vpc_cidr
    if contains(local.connected_accounts, k) && k != var.owning_account
  ]
}

module "tgw_vpc_attachment" {
  source = "git::https://github.com/cloudposse/terraform-aws-transit-gateway.git?ref=tags/0.2.1"

  existing_transit_gateway_id             = var.tgw_config.existing_transit_gateway_id
  existing_transit_gateway_route_table_id = var.tgw_config.existing_transit_gateway_route_table_id

  route_keys_enabled                                             = true
  create_transit_gateway                                         = false
  create_transit_gateway_route_table                             = false
  create_transit_gateway_vpc_attachment                          = true
  create_transit_gateway_route_table_association_and_propagation = false

  config = {
    (var.owning_account) = {
      vpc_id                            = local.own_vpc.vpc_id
      vpc_cidr                          = local.own_vpc.vpc_cidr
      subnet_ids                        = local.own_vpc.private_subnet_ids
      subnet_route_table_ids            = local.own_vpc.private_route_table_ids
      route_to                          = null
      static_routes                     = null
      transit_gateway_vpc_attachment_id = null
      route_to_cidr_blocks              = local.allowed_cidrs
    }
  }

  context = module.this.context
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  for_each = var.tgw_config.expose_eks_sg ? toset(local.connected_accounts) : []

  description       = "Allow inbound traffic from ${each.key}"
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [local.vpcs[each.key].outputs.vpc_cidr]
  security_group_id = local.own_eks_sg
}
