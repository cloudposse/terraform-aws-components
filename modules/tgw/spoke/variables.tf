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
  description = "A list of static routes to add to the transit gateway, pointing at this VPC as a destination."
  default     = []
}

variable "static_tgw_routes" {
  type        = list(string)
  description = "A list of static routes to add to the local routing table with the transit gateway as a destination."
  default     = []
}

variable "default_route_enabled" {
  type        = bool
  description = "Enable default routing via transit gateway, requires also nat gateway and instance to be disabled in vpc component. Default is disabled."
  default     = false
}

variable "default_route_outgoing_account_name" {
  type        = string
  description = "The account name which is used for outgoing traffic, when using the transit gateway as default route."
  default     = null
}

variable "cross_region_hub_connector_components" {
  type        = map(object({ component = string, environment = string }))
  description = <<-EOT
  A map of cross-region hub connector components that provide this spoke with the appropriate Transit Gateway attachments IDs.
  - The key should be the environment that the remote VPC is located in.
  - The component is the name of the component in the remote region (e.g. `tgw/cross-region-hub-connector`)
  - The environment is the region that the cross-region-hub-connector is deployed in.
  e.g. the following would configure a component called `tgw/cross-region-hub-connector/use1` that is deployed in the
  If use2 is the primary region, the following would be its configuration:
  use1:
    component: "tgw/cross-region-hub-connector"
    environment: "use1" (the remote region)
  and in the alternate region, the following would be its configuration:
  use2:
    component: "tgw/cross-region-hub-connector"
    environment: "use1" (our own region)
  EOT
  default     = {}
}
