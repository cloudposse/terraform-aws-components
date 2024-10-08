variable "region" {
  type        = string
  description = "AWS Region"
  nullable    = false
}

variable "vpc_component_name" {
  type        = string
  description = "Atmos VPC component name"
  default     = "vpc"
  nullable    = false
}

variable "customer_gateway_bgp_asn" {
  type        = number
  description = "The Customer Gateway's Border Gateway Protocol (BGP) Autonomous System Number (ASN)"
  nullable    = false
}

variable "customer_gateway_ip_address" {
  type        = string
  description = "The IPv4 address for the Customer Gateway device's outside interface. Set to `null` to not create the Customer Gateway"
  default     = null
}

variable "vpn_gateway_amazon_side_asn" {
  type        = number
  description = "The Autonomous System Number (ASN) for the Amazon side of the VPN Gateway. If you don't specify an ASN, the Virtual Private Gateway is created with the default ASN"
  default     = null
}

variable "vpn_connection_static_routes_only" {
  type        = bool
  description = "If set to `true`, the VPN connection will use static routes exclusively. Static routes must be used for devices that don't support BGP"
  default     = false
  nullable    = false
}

variable "vpn_connection_static_routes_destinations" {
  type        = list(string)
  description = "List of CIDR blocks to be used as destination for static routes. Routes to destinations will be propagated to the VPC route tables"
  default     = []
  nullable    = false
}

variable "vpn_connection_local_ipv4_network_cidr" {
  type        = string
  description = "The IPv4 CIDR on the Customer Gateway (on-premises) side of the VPN connection"
  default     = "0.0.0.0/0"
}

variable "vpn_connection_remote_ipv4_network_cidr" {
  type        = string
  description = "The IPv4 CIDR on the AWS side of the VPN connection"
  default     = "0.0.0.0/0"
}

variable "vpn_connection_log_retention_in_days" {
  type        = number
  description = "Specifies the number of days you want to retain log events"
  default     = 30
  nullable    = false
}

variable "vpn_connection_tunnel1_dpd_timeout_action" {
  type        = string
  description = "The action to take after DPD timeout occurs for the first VPN tunnel. Specify restart to restart the IKE initiation. Specify `clear` to end the IKE session. Valid values are `clear` | `none` | `restart`"
  default     = "clear"
  nullable    = false
}

variable "vpn_connection_tunnel1_ike_versions" {
  type        = list(string)
  description = "The IKE versions that are permitted for the first VPN tunnel. Valid values are ikev1 | ikev2"
  default     = []
  nullable    = false
}

variable "vpn_connection_tunnel1_inside_cidr" {
  type        = string
  description = "The CIDR block of the inside IP addresses for the first VPN tunnel"
  default     = null
}

variable "vpn_connection_tunnel1_phase1_encryption_algorithms" {
  type        = list(string)
  description = "List of one or more encryption algorithms that are permitted for the first VPN tunnel for phase 1 IKE negotiations. Valid values are AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16"
  default     = []
  nullable    = false
}

variable "vpn_connection_tunnel1_phase2_encryption_algorithms" {
  type        = list(string)
  description = "List of one or more encryption algorithms that are permitted for the first VPN tunnel for phase 2 IKE negotiations. Valid values are AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16"
  default     = []
  nullable    = false
}

variable "vpn_connection_tunnel1_phase1_integrity_algorithms" {
  type        = list(string)
  description = "One or more integrity algorithms that are permitted for the first VPN tunnel for phase 1 IKE negotiations. Valid values are SHA1 | SHA2-256 | SHA2-384 | SHA2-512"
  default     = []
  nullable    = false
}

variable "vpn_connection_tunnel1_phase2_integrity_algorithms" {
  type        = list(string)
  description = "One or more integrity algorithms that are permitted for the first VPN tunnel for phase 2 IKE negotiations. Valid values are SHA1 | SHA2-256 | SHA2-384 | SHA2-512"
  default     = []
  nullable    = false
}

variable "vpn_connection_tunnel1_phase1_dh_group_numbers" {
  type        = list(string)
  description = "List of one or more Diffie-Hellman group numbers that are permitted for the first VPN tunnel for phase 1 IKE negotiations. Valid values are 2 | 5 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24"
  default     = []
  nullable    = false
}

variable "vpn_connection_tunnel1_phase2_dh_group_numbers" {
  type        = list(string)
  description = "List of one or more Diffie-Hellman group numbers that are permitted for the first VPN tunnel for phase 2 IKE negotiations. Valid values are 2 | 5 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24"
  default     = []
  nullable    = false
}

variable "vpn_connection_tunnel1_preshared_key" {
  type        = string
  description = "The preshared key of the first VPN tunnel. The preshared key must be between 8 and 64 characters in length and cannot start with zero. Allowed characters are alphanumeric characters, periods(.) and underscores(_)"
  default     = null
}

variable "vpn_connection_tunnel1_startup_action" {
  type        = string
  description = "The action to take when the establishing the tunnel for the first VPN connection. By default, your customer gateway device must initiate the IKE negotiation and bring up the tunnel. Specify `start` for AWS to initiate the IKE negotiation. Valid values are `add` | `start`"
  default     = "add"
  nullable    = false
}

variable "vpn_connection_tunnel1_cloudwatch_log_enabled" {
  type        = bool
  description = "Enable or disable VPN tunnel logging feature for the tunnel"
  default     = false
  nullable    = false
}

variable "vpn_connection_tunnel1_cloudwatch_log_output_format" {
  type        = string
  description = "Set log format for the tunnel. Default format is json. Possible values are `json` and `text`"
  default     = "json"
  nullable    = false
}

variable "vpn_connection_tunnel2_dpd_timeout_action" {
  type        = string
  description = "The action to take after DPD timeout occurs for the second VPN tunnel. Specify restart to restart the IKE initiation. Specify clear to end the IKE session. Valid values are `clear` | `none` | `restart`"
  default     = "clear"
  nullable    = false
}

variable "vpn_connection_tunnel2_ike_versions" {
  type        = list(string)
  description = "The IKE versions that are permitted for the second VPN tunnel. Valid values are ikev1 | ikev2"
  default     = []
  nullable    = false
}

variable "vpn_connection_tunnel2_inside_cidr" {
  type        = string
  description = "The CIDR block of the inside IP addresses for the second VPN tunnel"
  default     = null
}

variable "vpn_connection_tunnel2_phase1_encryption_algorithms" {
  type        = list(string)
  description = "List of one or more encryption algorithms that are permitted for the second VPN tunnel for phase 1 IKE negotiations. Valid values are AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16"
  default     = []
  nullable    = false
}

variable "vpn_connection_tunnel2_phase2_encryption_algorithms" {
  type        = list(string)
  description = "List of one or more encryption algorithms that are permitted for the second VPN tunnel for phase 2 IKE negotiations. Valid values are AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16"
  default     = []
  nullable    = false
}

variable "vpn_connection_tunnel2_phase1_integrity_algorithms" {
  type        = list(string)
  description = "One or more integrity algorithms that are permitted for the second VPN tunnel for phase 1 IKE negotiations. Valid values are SHA1 | SHA2-256 | SHA2-384 | SHA2-512"
  default     = []
  nullable    = false
}

variable "vpn_connection_tunnel2_phase2_integrity_algorithms" {
  type        = list(string)
  description = "One or more integrity algorithms that are permitted for the second VPN tunnel for phase 2 IKE negotiations. Valid values are SHA1 | SHA2-256 | SHA2-384 | SHA2-512"
  default     = []
  nullable    = false
}

variable "vpn_connection_tunnel2_phase1_dh_group_numbers" {
  type        = list(string)
  description = "List of one or more Diffie-Hellman group numbers that are permitted for the second VPN tunnel for phase 1 IKE negotiations. Valid values are 2 | 5 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24"
  default     = []
  nullable    = false
}

variable "vpn_connection_tunnel2_phase2_dh_group_numbers" {
  type        = list(string)
  description = "List of one or more Diffie-Hellman group numbers that are permitted for the second VPN tunnel for phase 2 IKE negotiations. Valid values are 2 | 5 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24"
  default     = []
  nullable    = false
}

variable "vpn_connection_tunnel2_preshared_key" {
  type        = string
  description = "The preshared key of the second VPN tunnel. The preshared key must be between 8 and 64 characters in length and cannot start with zero. Allowed characters are alphanumeric characters, periods(.) and underscores(_)"
  default     = null
}

variable "vpn_connection_tunnel2_startup_action" {
  type        = string
  description = "The action to take when the establishing the tunnel for the second VPN connection. By default, your customer gateway device must initiate the IKE negotiation and bring up the tunnel. Specify `start` for AWS to initiate the IKE negotiation. Valid values are `add` | `start`"
  default     = "add"
  nullable    = false
}

variable "vpn_connection_tunnel2_cloudwatch_log_enabled" {
  type        = bool
  description = "Enable or disable VPN tunnel logging feature for the tunnel"
  default     = false
  nullable    = false
}

variable "vpn_connection_tunnel2_cloudwatch_log_output_format" {
  type        = string
  description = "Set log format for the tunnel. Default format is json. Possible values are `json` and `text`"
  default     = "json"
  nullable    = false
}

variable "existing_transit_gateway_id" {
  type        = string
  default     = ""
  description = "Existing Transit Gateway ID. If provided, the module will not create a Virtual Private Gateway but instead will use the transit_gateway. For setting up transit gateway we can use the cloudposse/transit-gateway/aws module and pass the output transit_gateway_id to this variable"
}

variable "transit_gateway_enabled" {
  type        = bool
  description = "Set to true to enable VPN connection to transit gateway and then pass in the existing_transit_gateway_id"
  default     = false
  nullable    = false
}

variable "transit_gateway_route_table_id" {
  type        = string
  description = "The ID of the route table for the transit gateway that you want to associate + propagate the VPN connection's TGW attachment"
  default     = null
}

variable "transit_gateway_routes" {
  type = map(object({
    blackhole              = optional(bool, false)
    destination_cidr_block = string
  }))
  description = "A map of transit gateway routes to create on the given TGW route table (via `transit_gateway_route_table_id`) for the created VPN Attachment. Use the key in the map to describe the route"
  default     = {}
  nullable    = false
}

variable "preshared_key_enabled" {
  type        = bool
  description = "Flag to enable adding the preshared keys to the VPN connection"
  default     = true
  nullable    = false
}

variable "ssm_enabled" {
  type        = bool
  description = "Flag to enable saving the `tunnel1_preshared_key` and `tunnel2_preshared_key` in the SSM Parameter Store"
  default     = false
  nullable    = false
}

variable "ssm_path_prefix" {
  type        = string
  description = "SSM Key path prefix for the associated SSM parameters"
  default     = ""
  nullable    = false
}
