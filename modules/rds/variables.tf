variable "region" {
  type        = string
  description = "AWS Region"
}

variable "dns_gbl_delegated_environment_name" {
  type        = string
  description = "The name of the environment where global `dns_delegated` is provisioned"
  default     = "gbl"
}

variable "use_eks_security_group" {
  type        = bool
  description = "Use the eks default security group"
  default     = false
}

variable "client_security_group_enabled" {
  type        = bool
  description = "create a client security group and include in attached default security group"
  default     = true
}
