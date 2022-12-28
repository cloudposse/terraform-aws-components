variable "region" {
  type        = string
  description = "AWS Region"
}

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
}

variable "chart_values" {
  type        = any
  description = "Addition map values to yamlencode as `helm_release` values."
  default     = {}
}
