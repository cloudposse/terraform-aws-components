variable "spaces" {
  type = map(object({
    parent_space_id  = string,
    description      = optional(string),
    inherit_entities = optional(bool, false),
    labels           = optional(set(string), []),
    policies = optional(map(object({
      body             = optional(string),
      body_url         = optional(string),
      body_url_version = optional(string, "master"),
      type             = optional(string),
      labels           = optional(set(string), []),
    })), {}),
  }))
  description = "A map of all Spaces to create in Spacelift"
}

variable "ssm_params_enabled" {
  type        = bool
  description = "Whether to write the IDs of the created spaces to SSM parameters"
  default     = true
}
