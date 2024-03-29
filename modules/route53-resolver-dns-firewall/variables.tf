variable "region" {
  type        = string
  description = "AWS Region"
}

variable "vpc_component_name" {
  type        = string
  description = "The name of a VPC component where the Network Firewall is provisioned"
}

variable "logs_bucket_component_name" {
  type        = string
  description = "Flow logs bucket component name"
  default     = null
}

variable "firewall_fail_open" {
  type        = string
  description = <<-EOF
    Determines how Route 53 Resolver handles queries during failures, for example when all traffic that is sent to DNS Firewall fails to receive a reply.
    By default, fail open is disabled, which means the failure mode is closed.
    This approach favors security over availability. DNS Firewall blocks queries that it is unable to evaluate properly.
    If you enable this option, the failure mode is open. This approach favors availability over security.
    In this case, DNS Firewall allows queries to proceed if it is unable to properly evaluate them.
    Valid values: ENABLED, DISABLED.
  EOF
  default     = "ENABLED"
}

variable "query_log_enabled" {
  type        = bool
  description = "Flag to enable/disable Route 53 Resolver query logging"
  default     = false
}

variable "query_log_config_name" {
  type        = string
  description = "Route 53 Resolver query log config name. If omitted, the name will be generated by concatenating the ID from the context with the VPC ID"
  default     = null
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_domain_list
variable "domains_config" {
  type = map(object({
    domains      = optional(list(string))
    domains_file = optional(string)
  }))
  description = "Map of Route 53 Resolver DNS Firewall domain configurations"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_rule_group
variable "rule_groups_config" {
  type = map(object({
    priority            = number
    mutation_protection = optional(string)
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_rule
    rules = map(object({
      action                    = string
      priority                  = number
      block_override_dns_type   = optional(string)
      block_override_domain     = optional(string)
      block_override_ttl        = optional(number)
      block_response            = optional(string)
      firewall_domain_list_name = string
    }))
  }))
  description = "Rule groups and rules configuration"
}
