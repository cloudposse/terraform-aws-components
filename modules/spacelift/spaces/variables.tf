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
      body_file_path   = optional(string),
      type             = optional(string),
      labels           = optional(set(string), []),
    })), {}),
  }))
  description = "A map of all Spaces to create in Spacelift"
}
