locals {
  # Context note: Originally the additional_routes came from a variable `additional_routes`.
  # In order to reduce redundancy of defining CIDR blocks for both this variable and `var.authorization_rules`,
  # we can instead pull the list of additional routes from `var.authorization_rules`
  additional_routes = flatten(
    [
      for rule in var.authorization_rules : [
        for subnet_id in module.vpc.outputs.private_subnet_ids : {
          destination_cidr_block = rule.target_network_cidr
          description            = rule.description
          target_vpc_subnet_id   = subnet_id
        }
      ]
    ]
  )

  authorization_rules = [
    for private_subnet_cidr in module.vpc.outputs.private_subnet_cidrs : {
      name                 = "Internal Rule"
      access_group_id      = null
      authorize_all_groups = true
      description          = "Internal authorization rule"
      target_network_cidr  = private_subnet_cidr
    }
  ]

  associated_security_group_ids = concat([
    module.vpc.outputs.vpc_default_security_group_id
  ], var.associated_security_group_ids)
}

module "ec2_client_vpn" {
  source  = "cloudposse/ec2-client-vpn/aws"
  version = "0.14.0"

  ca_common_name     = var.ca_common_name
  root_common_name   = var.root_common_name
  server_common_name = var.server_common_name

  client_cidr                   = var.client_cidr
  authentication_type           = var.authentication_type
  organization_name             = var.organization_name
  logging_enabled               = var.logging_enabled
  logging_stream_name           = var.logging_stream_name
  retention_in_days             = var.retention_in_days
  associated_subnets            = module.vpc.outputs.private_subnet_ids
  authorization_rules           = concat(local.authorization_rules, var.authorization_rules)
  additional_routes             = local.additional_routes
  associated_security_group_ids = local.associated_security_group_ids
  vpc_id                        = module.vpc.outputs.vpc_id
  export_client_certificate     = var.export_client_certificate
  saml_provider_arn             = var.saml_provider_arn
  saml_metadata_document        = file(var.saml_metadata_document)
  dns_servers                   = var.dns_servers
  split_tunnel                  = var.split_tunnel

  context = module.this.context
}
