variable "region" {
  type        = string
  description = "AWS Region"
}

variable "rbac_enabled" {
  type        = bool
  default     = true
  description = "Service Account for pods."
}

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
}

variable "parameter_store_paths" {
  type        = set(string)
  description = "A list of path prefixes that the SecretStore is allowed to access via IAM. This should match the convention 'service' that Chamber uploads keys under."
  default     = ["app"]
}

variable "resources" {
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  description = "The cpu and memory of the deployment's limits and requests."
}
