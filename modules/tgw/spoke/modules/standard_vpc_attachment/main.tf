locals {
  vpcs = var.tgw_config.vpcs
  eks  = var.tgw_config.eks

  own_account_vpc_key = "${var.owning_account}-${var.own_vpc_component_name}"
  own_vpc             = local.vpcs[local.own_account_vpc_key].outputs

  # Create a list of all VPC component keys. Key includes stack + component
  #
  # Example var.connections
  #  connections:
  #    - account:
  #        tenant: core
  #        stage: network
  #      vpc_component_names:
  #        - vpc-dev
  #    - account:
  #        tenant: core
  #        stage: auto
  connected_vpc_component_keys = flatten(
    [
      for c in var.connections :
      [
        # Default value for c.vpc_component_names is ["vpc"]
        for vpc in c.vpc_component_names :
        # This component key needs to match the key created by tgw/hub
        # See components/terraform/tgw/hub/remote-state.tf
        length(c.account.tenant) > 0 ? "${c.account.tenant}-${c.account.stage}-${vpc}" : "${c.account.stage}-${vpc}"
      ]
    ]
  )

  # Create a list of all EKS component keys. 
  # Follows same pattern as vpc_component_names
  connected_eks_component_keys = flatten(
    [
      for c in var.connections :
      [
        for eks in c.eks_component_names :
        length(c.account.tenant) > 0 ? "${c.account.tenant}-${c.account.stage}-${eks}" : "${c.account.stage}-${eks}"
      ]
    ]
  )

  # Define a list of all VPCs allowed to access this account's VPC.
  # Filter the tgw_config output from tgw/hub for VPCs and pull the CIDR of a VPC if
  # (1) this is not the primary VPC that we are connecting to and (2) this VPC key is given as a connection
  allowed_vpcs = {
    for vpc_key, vpc_remote_state in local.vpcs :
    vpc_key => {
      cidr = vpc_remote_state.outputs.vpc_cidr
    } if vpc_key != local.own_account_vpc_key && contains(local.connected_vpc_component_keys, vpc_key)
  }

  # Define a list of all EKS clusters allowed for this account's VPC
  allowed_eks = {
    for eks_key, eks_remote_state in local.eks :
    eks_key => {
      sg_id = eks_remote_state.outputs.eks_cluster_managed_security_group_id
      cidr  = eks_remote_state.outputs.vpc_cidr
    } if contains(local.connected_eks_component_keys, eks_key)
  }

}

# Create a TGW attachment from this account's VPC to the TGW Hub
# This includes a merged list of all CIDRs from allowed VPCs in connected accounts
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
      route_to_cidr_blocks              = [for vpc in local.allowed_vpcs : vpc.cidr]
    }
  }

  context = module.this.context
}

# Define a Security Group Rule in this account for each EKS Security Group
resource "aws_security_group_rule" "ingress_cidr_blocks" {
  for_each = var.expose_eks_sg ? local.allowed_eks : {}

  description       = "Allow inbound traffic from ${each.key}"
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [each.value.cidr]
  security_group_id = each.value.sg_id
}
