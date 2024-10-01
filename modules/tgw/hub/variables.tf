variable "region" {
  type        = string
  description = "AWS Region"
}

variable "expose_eks_sg" {
  type        = bool
  description = "Set true to allow EKS clusters to accept traffic from source accounts"
  default     = true
}

variable "connections" {
  type = list(object({
    account = object({
      stage       = string
      environment = optional(string, "")
      tenant      = optional(string, "")
    })
    vpc_component_names = optional(list(string), ["vpc"])
    eks_component_names = optional(list(string), [])
  }))
  description = <<-EOT
  A list of objects to define each TGW connections.

  By default, each connection will look for only the default `vpc` component.
  EOT
  default     = []
}

variable "account_map_environment_name" {
  type        = string
  description = "The name of the environment where `account_map` is provisioned"
  default     = "gbl"
}

variable "account_map_stage_name" {
  type        = string
  description = "The name of the stage where `account_map` is provisioned"
  default     = "root"
}

variable "account_map_tenant_name" {
  type        = string
  description = <<-EOT
  The name of the tenant where `account_map` is provisioned.

  If the `tenant` label is not used, leave this as `null`.
  EOT
  default     = null
}

variable "ram_principals" {
  type        = list(string)
  description = "A list of AWS account IDs to share the TGW with outside the organization"
  default     = []
}

variable "allow_external_principals" {
  type        = bool
  description = "Set true to allow the TGW to be RAM shared with external principals specified in ram_principals"
  default     = false
}
