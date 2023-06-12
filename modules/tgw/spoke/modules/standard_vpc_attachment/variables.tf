variable "owning_account" {
  type        = string
  default     = null
  description = "The name of the account that owns the VPC being attached"
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

variable "tgw_config" {
  type = object({
    existing_transit_gateway_id             = string
    existing_transit_gateway_route_table_id = string
    vpcs                                    = any
    eks                                     = any
  })
  description = "Object to pass common data from root module to this submodule. See root module for details"
}

variable "connections" {
  type = list(object({
    account = object({
      stage  = string
      tenant = optional(string, "")
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

variable "expose_eks_sg" {
  type        = bool
  description = "Set true to allow EKS clusters to accept traffic from source accounts"
  default     = true
}
