# This input is unused however, this is added by default to every component by atmos
# and this is defined to avoid any `var.region` warnings.
# tflint-ignore: terraform_unused_declarations
variable "region" {
  type        = string
  description = "AWS Region"
}

variable "policy_version" {
  type        = string
  description = "The optional global policy version injected using a %s in each `body_url`. This can be pinned to a version tag or a branch."
  default     = "master"
}

variable "policies" {
  type        = any
  description = "The map of required policies to add."
}

variable "labels" {
  type        = list(string)
  description = "List of global labels to add to each policy. These values can be overridden in `var.policies`'s per policy `labels` key."
  default     = []
}

variable "space_id" {
  type        = string
  description = "The global `space_id` to assign to each policy. This value can be overridden in `var.policies`'s per policy `space_id` key."
  default     = "root"
}
