# This input is unused however, this is added by default to every component by atmos
# and this is defined to avoid any `var.region` warnings.
# tflint-ignore: terraform_unused_declarations
variable "region" {
  type        = string
  description = "AWS Region"
}

variable "spaces" {
  type        = any
  description = "The map of required spaces to add."
}

variable "parent_space_id" {
  type        = string
  description = "The parent space id to attach to each spacelift space"
  default     = null
}

variable "inherit_entities" {
  type        = bool
  description = "Indication whether access to this space inherits read access to entities from the parent space"
  default     = false
}

variable "description" {
  type        = string
  description = "Free-form space description for users"
  default     = null
}

variable "labels" {
  type        = list(string)
  description = "List of global labels to add to each space. These values can be overridden in `var.spaces`'s per space `labels` key."
  default     = []
}
