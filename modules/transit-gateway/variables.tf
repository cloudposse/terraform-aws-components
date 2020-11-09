variable "region" {
  type        = string
  description = "AWS Region"
}

variable "accounts_with_vpc" {
  type        = set(string)
  description = "Set of account names that have VPC"
}

variable "connections" {
  type        = map(list(string))
  description = "For each account, a list of accounts to connect to"
}

variable "expose_eks_sg" {
  type        = bool
  description = "Set true to allow EKS clusters to accept traffic from source accounts"
  default     = true
}

variable "tgw_stage_name" {
  type        = string
  description = "The name of the stage where the Transit Gateway is provisioned"
  default     = "network"
}
