# The variables are defined in the global Terraform configurations
# and Terraform complains if they are not defined in the module.

variable "region_availability_zones" {
  type        = list(string)
  default     = []
  description = "List of availability zones in region, to be used as default when `availability_zones` is not supplied"
}

variable "subnet_type_tag_key" {
  type        = string
  default     = null
  description = "Key for subnet type tag to provide information about the type of subnets, e.g. `cpco/subnet/type=private` or `cpco/subnet/type=public`"
}

variable "account_number" {
  type        = string
  default     = null
  description = "AWS account number for the target account (where resources are being created)"
}
