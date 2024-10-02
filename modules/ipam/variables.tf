variable "region" {
  type        = string
  description = "AWS Region"
}

variable "account_map_environment_name" {
  type        = string
  description = "The name of the environment where `account_map` is provisioned"
  default     = "gbl"
}

variable "account_map_stage_name" {
  type        = string
  description = "The name of the stage where `account_map` is provisioned"
  default     = "root"
}

variable "account_map_tenant_name" {
  type        = string
  description = <<-EOT
  The name of the tenant where `account_map` is provisioned.

  If the `tenant` label is not used, leave this as `null`.
  EOT
  default     = null
}

# Copied from upstream module's variables.tf

variable "pool_configurations" {
  description = "A multi-level, nested map describing nested IPAM pools. Can nest up to three levels with the top level being outside the `pool_configurations`. This attribute is quite complex, see README.md for further explanation."
  type        = any

  # Below is an example of the actual expected structure for `pool_configurations`. type = any is currently being used, may adjust in the future

  # type        = object({
  #   cidr                 = optional(list(string))
  #   ram_share_principals = optional(list(string))
  #   locale                            = optional(string)
  #   allocation_default_netmask_length = optional(string)
  #   allocation_max_netmask_length     = optional(string)
  #   allocation_min_netmask_length     = optional(string)
  #   auto_import                       = optional(string)
  #   aws_service                       = optional(string)
  #   description                       = optional(string)
  #   name                              = optional(string)
  #   publicly_advertisable             = optional(bool)
  #   allocation_resource_tags   = optional(map(string))
  #   tags                       = optional(map(string))
  #   cidr_authorization_context = optional(map(string))

  #   sub_pools = (repeat of pool_configuration object above )
  # })
  default = {}

  # Validate no more than 3 layers of sub_pools specified
  # TODO: fix validation, fails if less than 2 layers of pools
  # validation {
  #   error_message = "Sub pools (sub_pools) is defined in the 3rd level of a nested pool. Sub pools can only be defined up to 3 levels."
  #   condition     = flatten([for k, v in var.pool_configurations : [for k2, v2 in v.sub_pools : [for k3, v3 in try(v2.sub_pools, []) : "${k}/${k2}/${k3}" if try(v3.sub_pools, []) != []]]]) == []
  # }
}

variable "top_cidr" {
  description = "Top-level CIDR blocks."
  type        = list(string)
}

variable "top_ram_share_principals" {
  description = "Principals to create RAM shares for top-level pool."
  type        = list(string)
  default     = null
}

variable "top_auto_import" {
  description = "`auto_import` setting for top-level pool."
  type        = bool
  default     = null
}

variable "top_description" {
  description = "Description of top-level pool."
  type        = string
  default     = ""
}

variable "top_cidr_authorization_context" {
  description = "A signed document that proves that you are authorized to bring the specified IP address range to Amazon using BYOIP. Document is not stored in the state file. For more information, refer to https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipam_pool_cidr#cidr_authorization_context."
  type        = any
  default     = null
}

variable "address_family" {
  description = "IPv4/6 address family."
  type        = string
  default     = "ipv4"
  validation {
    condition     = var.address_family == "ipv4" || var.address_family == "ipv6"
    error_message = "Only valid options: \"ipv4\", \"ipv6\"."
  }
}

variable "ipam_scope_id" {
  description = "(Optional) Required if `var.ipam_id` is set. Determines which scope to deploy pools into."
  type        = string
  default     = null
}

variable "ipam_scope_type" {
  description = "Which scope type to use. Valid inputs include `public` or `private`. You can alternatively provide your own scope ID."
  type        = string
  default     = "private"

  validation {
    condition     = var.ipam_scope_type == "public" || var.ipam_scope_type == "private"
    error_message = "Scope type must be either public or private."
  }
}
