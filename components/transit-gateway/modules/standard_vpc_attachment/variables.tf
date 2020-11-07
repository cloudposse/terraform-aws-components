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
    # Routes will be created from the owning account's VPC to the accounts
    # specified in the connected_accounts map for the owning account
    connected_accounts = map(list(string))
    expose_eks_sg      = bool
  })
  description = "Object to pass common data from root module to this submodule. See root module for details"
}
