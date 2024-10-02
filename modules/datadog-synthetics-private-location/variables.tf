variable "region" {
  type        = string
  description = "AWS Region"
}

variable "private_location_tags" {
  type        = set(string)
  description = "List of static tags to associate with the synthetics private location"
  default     = []
}

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
}
