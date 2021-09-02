variable "region" {
  type        = string
  description = "VPN Endpoints are region-specific. This identifies the region. AWS Region"
} 

variable "client_cidr" {
  description = "Network CIDR to use for clients"
}

variable "aws_subnet_id" {
  type        = string
  description = "The Subnet ID to associate with the Client VPN Endpoint."
}

variable "aws_authorization_rule_target_cidr" {
  type        = string
  description = "The target CIDR address within your VPC that you would like to provider authorization for."
}

variable "logging_enabled" {
  type        = bool
  default     = false
  description = "Enables or disables Client VPN Cloudwatch logging."
}

variable "logs_retention" {
  type        = number
  default     = 365
  description = "Retention in days for CloudWatch Log Group"
}

variable "internet_access_enabled" {
  type        = bool
  default     = true
  description = <<-EOT
Enables an authorization rule and route for the VPN to access the internet.
Please note, you must allow ingress/egress to the internet (0.0.0.0/0) via the Subnet's security group.
EOT
}

variable "organization_name" {
  type        = string
  description = "Name of organization to use in private certificate"
}