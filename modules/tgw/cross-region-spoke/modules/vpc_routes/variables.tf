variable "vpc_name" {
  type        = string
  default     = null
  description = "The name of the account that owns the VPC being configured"
}

variable "vpc_config" {
  type = object({
    transit_gateway_id = string
    vpcs_this_region   = any
    vpcs_home_region   = any
    connected_vpcs     = list(string)
  })
  description = "VPC cross region routes configuration"
}
