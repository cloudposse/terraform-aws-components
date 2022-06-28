# Create the Transit Gateway, route table associations/propagations, and static TGW routes in the `network` account.
# Enable sharing the Transit Gateway with the Organization using Resource Access Manager (RAM).
# If you would like to share resources with your organization or organizational units,
# then you must use the AWS RAM console or CLI command to enable sharing with AWS Organizations.
# When you share resources within your organization,
# AWS RAM does not send invitations to principals. Principals in your organization get access to shared resources without exchanging invitations.
# https://docs.aws.amazon.com/ram/latest/userguide/getting-started-sharing.html

module "tgw_hub" {
  source  = "cloudposse/transit-gateway/aws"
  version = "0.9.1"

  ram_resource_share_enabled = true
  route_keys_enabled         = true

  create_transit_gateway                                         = true
  create_transit_gateway_route_table                             = true
  create_transit_gateway_vpc_attachment                          = false
  create_transit_gateway_route_table_association_and_propagation = false

  config = {}

  context = module.this.context
}

locals {
  tgw_config = {
    existing_transit_gateway_id             = module.tgw_hub.transit_gateway_id
    existing_transit_gateway_route_table_id = module.tgw_hub.transit_gateway_route_table_id
    vpcs                                    = module.vpc
    eks                                     = module.eks
    expose_eks_sg                           = var.expose_eks_sg
    eks_component_names                     = var.eks_component_names
  }
}
