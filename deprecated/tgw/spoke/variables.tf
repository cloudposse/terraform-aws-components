variable "region" {
  type        = string
  description = "AWS Region"
}

variable "connections" {
  type        = list(string)
  description = "List of accounts to connect to"
}

variable "tgw_hub_component_name" {
  type        = string
  description = "The name of the transit-gateway component"
  default     = "tgw/hub"
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
