variable "region" {
  type        = string
  description = "VPN Endpoints are region-specific. This identifies the region. AWS Region"
}

variable "client_cidr" {
  type        = string
  description = "Network CIDR to use for clients"
}

variable "logging_enabled" {
  type        = bool
  default     = false
  description = "Enables or disables Client VPN Cloudwatch logging."
}

variable "authentication_type" {
  type        = string
  default     = "certificate-authentication"
  description = <<-EOT
    One of `certificate-authentication` or `federated-authentication`
  EOT
  validation {
    condition     = contains(["certificate-authentication", "federated-authentication"], var.authentication_type)
    error_message = "VPN client authentication type must one be one of: certificate-authentication, federated-authentication."
  }
}

variable "organization_name" {
  type        = string
  description = "Name of organization to use in private certificate"
}

variable "retention_in_days" {
  type        = number
  description = "Number of days you want to retain log events in the log group"
  default     = 30
}

variable "logging_stream_name" {
  type        = string
  description = "Names of stream used for logging"
}

variable "associated_security_group_ids" {
  default     = []
  description = "List of security groups to attach to the client vpn network associations"
  type        = list(string)
}

variable "authorization_rules" {
  type = list(object({
    name                 = string
    access_group_id      = string
    authorize_all_groups = bool
    description          = string
    target_network_cidr  = string
  }))
  description = "List of objects describing the authorization rules for the Client VPN. Each Target Network CIDR range given will be used to create an additional route attached to the Client VPN endpoint with the same Description."
}

variable "ca_common_name" {
  default     = null
  type        = string
  description = "Unique Common Name for CA self-signed certificate"
}

variable "root_common_name" {
  default     = null
  type        = string
  description = "Unique Common Name for Root self-signed certificate"
}

variable "server_common_name" {
  default     = null
  type        = string
  description = "Unique Common Name for Server self-signed certificate"
}

variable "export_client_certificate" {
  default     = true
  type        = bool
  description = "Flag to determine whether to export the client certificate with the VPN configuration"
}

variable "saml_metadata_document" {
  default     = null
  description = "Optional SAML metadata document. Must include this or `saml_provider_arn`"
  type        = string
}

variable "saml_provider_arn" {
  default     = null
  description = "Optional SAML provider ARN. Must include this or `saml_metadata_document`"
  type        = string

  validation {
    error_message = "Invalid SAML provider ARN."

    condition = (
      var.saml_provider_arn == null ||
      try(length(regexall(
        "^arn:[^:]+:iam::(?P<account_id>\\d{12}):saml-provider\\/(?P<provider_name>[\\w+=,\\.@-]+)$",
        var.saml_provider_arn
        )) > 0,
        false
    ))
  }
}

variable "dns_servers" {
  default = []
  type    = list(string)
  validation {
    condition = can(
      [
        for server_ip in var.dns_servers : cidrnetmask("${server_ip}/32")
      ]
    )
    error_message = "IPv4 addresses must match the appropriate format xxx.xxx.xxx.xxx."
  }
  description = "Information about the DNS servers to be used for DNS resolution. A Client VPN endpoint can have up to two DNS servers. If no DNS server is specified, the DNS address of the VPC that is to be associated with Client VPN endpoint is used as the DNS server."
}

variable "split_tunnel" {
  default     = false
  type        = bool
  description = "Indicates whether split-tunnel is enabled on VPN endpoint. Default value is false."
}
