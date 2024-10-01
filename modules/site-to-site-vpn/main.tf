locals {
  enabled     = module.this.enabled
  vpc_outputs = module.vpc.outputs

  preshared_key_enabled = local.enabled && var.preshared_key_enabled

  tunnel1_preshared_key = local.preshared_key_enabled ? (
    length(var.vpn_connection_tunnel1_preshared_key) > 0 ? var.vpn_connection_tunnel1_preshared_key :
    one(random_password.tunnel1_preshared_key[*].result)
  ) : null

  tunnel2_preshared_key = local.preshared_key_enabled ? (
    length(var.vpn_connection_tunnel2_preshared_key) > 0 ? var.vpn_connection_tunnel2_preshared_key :
    one(random_password.tunnel2_preshared_key[*].result)
  ) : null
}

module "site_to_site_vpn" {
  source  = "cloudposse/vpn-connection/aws"
  version = "1.3.0"

  vpc_id                                              = local.vpc_outputs.vpc_id
  vpn_gateway_amazon_side_asn                         = var.vpn_gateway_amazon_side_asn
  customer_gateway_bgp_asn                            = var.customer_gateway_bgp_asn
  customer_gateway_ip_address                         = var.customer_gateway_ip_address
  route_table_ids                                     = local.vpc_outputs.private_route_table_ids
  vpn_connection_static_routes_only                   = var.vpn_connection_static_routes_only
  vpn_connection_static_routes_destinations           = var.vpn_connection_static_routes_destinations
  vpn_connection_tunnel1_inside_cidr                  = var.vpn_connection_tunnel1_inside_cidr
  vpn_connection_tunnel2_inside_cidr                  = var.vpn_connection_tunnel2_inside_cidr
  vpn_connection_tunnel1_preshared_key                = local.tunnel1_preshared_key
  vpn_connection_tunnel2_preshared_key                = local.tunnel2_preshared_key
  vpn_connection_local_ipv4_network_cidr              = var.vpn_connection_local_ipv4_network_cidr
  vpn_connection_remote_ipv4_network_cidr             = var.vpn_connection_remote_ipv4_network_cidr
  vpn_connection_tunnel1_ike_versions                 = var.vpn_connection_tunnel1_ike_versions
  vpn_connection_tunnel2_ike_versions                 = var.vpn_connection_tunnel2_ike_versions
  vpn_connection_tunnel1_phase1_encryption_algorithms = var.vpn_connection_tunnel1_phase1_encryption_algorithms
  vpn_connection_tunnel1_phase2_encryption_algorithms = var.vpn_connection_tunnel1_phase2_encryption_algorithms
  vpn_connection_tunnel1_phase1_integrity_algorithms  = var.vpn_connection_tunnel1_phase1_integrity_algorithms
  vpn_connection_tunnel1_phase2_integrity_algorithms  = var.vpn_connection_tunnel1_phase2_integrity_algorithms
  vpn_connection_tunnel2_phase1_encryption_algorithms = var.vpn_connection_tunnel2_phase1_encryption_algorithms
  vpn_connection_tunnel2_phase2_encryption_algorithms = var.vpn_connection_tunnel2_phase2_encryption_algorithms
  vpn_connection_tunnel2_phase1_integrity_algorithms  = var.vpn_connection_tunnel2_phase1_integrity_algorithms
  vpn_connection_tunnel2_phase2_integrity_algorithms  = var.vpn_connection_tunnel2_phase2_integrity_algorithms
  vpn_connection_tunnel1_phase1_dh_group_numbers      = var.vpn_connection_tunnel1_phase1_dh_group_numbers
  vpn_connection_tunnel1_phase2_dh_group_numbers      = var.vpn_connection_tunnel1_phase2_dh_group_numbers
  vpn_connection_tunnel2_phase1_dh_group_numbers      = var.vpn_connection_tunnel2_phase1_dh_group_numbers
  vpn_connection_tunnel2_phase2_dh_group_numbers      = var.vpn_connection_tunnel2_phase2_dh_group_numbers
  vpn_connection_tunnel1_startup_action               = var.vpn_connection_tunnel1_startup_action
  vpn_connection_tunnel2_startup_action               = var.vpn_connection_tunnel2_startup_action
  vpn_connection_log_retention_in_days                = var.vpn_connection_log_retention_in_days
  vpn_connection_tunnel1_dpd_timeout_action           = var.vpn_connection_tunnel1_dpd_timeout_action
  vpn_connection_tunnel2_dpd_timeout_action           = var.vpn_connection_tunnel2_dpd_timeout_action
  vpn_connection_tunnel1_cloudwatch_log_enabled       = var.vpn_connection_tunnel1_cloudwatch_log_enabled
  vpn_connection_tunnel2_cloudwatch_log_enabled       = var.vpn_connection_tunnel2_cloudwatch_log_enabled
  vpn_connection_tunnel1_cloudwatch_log_output_format = var.vpn_connection_tunnel1_cloudwatch_log_output_format
  vpn_connection_tunnel2_cloudwatch_log_output_format = var.vpn_connection_tunnel2_cloudwatch_log_output_format
  transit_gateway_enabled                             = var.transit_gateway_enabled
  existing_transit_gateway_id                         = var.existing_transit_gateway_id
  transit_gateway_route_table_id                      = var.transit_gateway_route_table_id
  transit_gateway_routes                              = var.transit_gateway_routes

  context = module.this.context
}

resource "random_password" "tunnel1_preshared_key" {
  count = local.preshared_key_enabled && length(var.vpn_connection_tunnel1_preshared_key) == 0 ? 1 : 0

  length = 60
  # Leave special characters out to avoid quoting and other issues.
  # Special characters have no additional security compared to increasing length.
  special          = false
  override_special = "!#$%^&*()<>-_"
}

resource "random_password" "tunnel2_preshared_key" {
  count = local.preshared_key_enabled && length(var.vpn_connection_tunnel2_preshared_key) == 0 ? 1 : 0

  length = 60
  # Leave special characters out to avoid quoting and other issues.
  # Special characters have no additional security compared to increasing length.
  special          = false
  override_special = "!#$%^&*()<>-_"
}
