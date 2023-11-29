variable "region" {
  type        = string
  description = "AWS Region"
}

variable "connections" {
  type = list(object({
    account = object({
      stage       = string
      environment = optional(string, "")
      tenant      = optional(string, "")
    })
    vpc_component_names = optional(list(string), ["vpc"])
    eks_component_names = optional(list(string), [])
  }))
  description = <<-EOT
  A list of objects to define each TGW connections.

  By default, each connection will look for only the default `vpc` component.
  EOT
  default     = []
}

variable "tgw_hub_component_name" {
  type        = string
  description = "The name of the transit-gateway component"
  default     = "tgw/hub"
}

variable "tgw_hub_stage_name" {
  type        = string
  description = "The name of the stage where `tgw/hub` is provisioned"
  default     = "network"
}

variable "tgw_hub_tenant_name" {
  type        = string
  description = <<-EOT
  The name of the tenant where `tgw/hub` is provisioned.

  If the `tenant` label is not used, leave this as `null`.
  EOT
  default     = null
}

variable "expose_eks_sg" {
  type        = bool
  description = "Set true to allow EKS clusters to accept traffic from source accounts"
  default     = true
}

variable "own_vpc_component_name" {
  type        = string
  default     = "vpc"
  description = "The name of the vpc component in the owning account. Defaults to \"vpc\""
}

variable "own_eks_component_names" {
  type        = list(string)
  default     = []
  description = "The name of the eks components in the owning account."
}

variable "peered_region" {
  type        = bool
  description = "Set `true` if this region is not the primary region"
  default     = false
}

variable "static_routes" {
  type = set(object({
    blackhole              = bool
    destination_cidr_block = string
  }))
  description = <<-EOT
  A list of static routes.
  EOT
  default     = []
}

variable "default_route_enabled" {
  type        = bool
  description = "Enable default routing via transit gateway, requires also nat gateway and instance to be disabled in vpc component. Default is disabled."
  default     = false
  validation {
    condition     = var.default_route_enabled ? (length(module.vpc.outputs.nat_gateway_ids) == 0 && length(module.vpc.outputs.nat_instance_ids) == 0 ? true : false) : true
    error_message = "When default routing via transit gateway is enabled, both nat gateway and nat instance must be disabled"
  }
}

variable "default_route_outgoing_account_name" {
  type        = string
  description = "The account name which is used for outgoing traffic, when using the transit gateway as default route."
  default     = null
}
