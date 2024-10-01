variable "region" {
  type        = string
  description = "AWS Region"
}

variable "auth0_app_connections" {
  type = list(object({
    component   = optional(string, "auth0/app")
    environment = optional(string, "")
    stage       = optional(string, "")
    tenant      = optional(string, "")
  }))
  default     = []
  description = "The list of Auth0 apps to add to this connection"
}

variable "strategy" {
  type        = string
  description = "The strategy to use for the connection"
  default     = "auth0"
}

variable "connection_name" {
  type        = string
  description = "The name of the connection"
  default     = ""
}

variable "options_name" {
  type        = string
  description = "The name of the connection options. Required for the email strategy."
  default     = ""
}

variable "email_from" {
  type        = string
  description = "When using an email strategy, the address to use as the sender"
  default     = null
}

variable "email_subject" {
  type        = string
  description = "When using an email strategy, the subject of the email"
  default     = null
}

variable "syntax" {
  type        = string
  description = "The syntax of the template body"
  default     = null
}

variable "disable_signup" {
  type        = bool
  description = "Indicates whether to allow user sign-ups to your application."
  default     = false
}

variable "brute_force_protection" {
  type        = bool
  description = "Indicates whether to enable brute force protection, which will limit the number of signups and failed logins from a suspicious IP address."
  default     = true
}

variable "set_user_root_attributes" {
  type        = string
  description = "Determines whether to sync user profile attributes at each login or only on the first login. Options include: `on_each_login`, `on_first_login`."
  default     = null
}

variable "non_persistent_attrs" {
  type        = list(string)
  description = "If there are user fields that should not be stored in Auth0 databases due to privacy reasons, you can add them to the DenyList here."
  default     = []
}

variable "auth_params" {
  type = object({
    scope         = optional(string, null)
    response_type = optional(string, null)
  })
  description = "Query string parameters to be included as part of the generated passwordless email link."
  default     = {}
}

variable "totp" {
  type = object({
    time_step = optional(number, 900)
    length    = optional(number, 6)
  })
  description = "The TOTP settings for the connection"
  default     = {}
}

variable "template_file" {
  type        = string
  description = "The path to the template file. If not provided, the `template` variable must be set."
  default     = ""
}

variable "template" {
  type        = string
  description = "The template to use for the connection. If not provided, the `template_file` variable must be set."
  default     = ""
}
