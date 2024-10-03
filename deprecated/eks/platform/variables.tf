variable "region" {
  type        = string
  description = "AWS Region"
}

variable "references" {
  description = "Platform mapping from remote components outputs"
  default     = {}
  type = map(object({
    component   = string
    privileged  = optional(bool)
    tenant      = optional(string)
    environment = optional(string)
    stage       = optional(string)
    output      = string
  }))
}

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
}

variable "ssm_platform_path" {
  type        = string
  description = "Format SSM path to store platform configs"
  default     = "/platform/%s/%s"
}

variable "platform_environment" {
  type        = string
  description = "Platform environment"
  default     = "default"
}
