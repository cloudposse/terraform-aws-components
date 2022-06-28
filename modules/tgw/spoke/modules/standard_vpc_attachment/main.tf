locals {
  vpcs               = var.tgw_config.vpcs
  own_vpc            = local.vpcs[var.owning_account].outputs
  connected_accounts = var.connections

  # Create a list of all of the EKS security groups
  own_eks_sgs = compact([
    for account_component in setproduct([var.owning_account], var.eks_component_names) :
    try(var.tgw_config.eks[join("-", account_component)].outputs.eks_cluster_managed_security_group_id, "")
  ])

  # Create a map of accounts (<tenant>-<stage> or <stage>) and the security group to add ingress rules for
  connected_accounts_allow_ingress = {
    for account_sg in setproduct(local.connected_accounts, local.own_eks_sgs) :
    account_sg[0] => {
      account = account_sg[0]
      sg      = account_sg[1]
    }
  }

  allowed_cidrs = [
    for k, v in local.vpcs : v.outputs.vpc_cidr
    if contains(local.connected_accounts, k) && k != var.owning_account
  ]
}

module "standard_vpc_attachment" {
  source  = "cloudposse/transit-gateway/aws"
  version = "0.9.1"

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
  for_each = var.expose_eks_sg ? local.connected_accounts_allow_ingress : {}

  description       = "Allow inbound traffic from ${each.key}"
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [local.vpcs[each.value.account].outputs.vpc_cidr]
  security_group_id = each.value.sg
}
