variable "owning_account" {
  type        = string
  default     = null
  description = "The name of the account that owns the VPC being attached"
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
  type        = list(string)
  description = "List of accounts to connect to"
}

variable "expose_eks_sg" {
  type        = bool
  description = "Set true to allow EKS clusters to accept traffic from source accounts"
  default     = true
}

variable "eks_component_names" {
  type        = set(string)
  description = "The names of the eks components"
  default     = ["eks/cluster"]
}
