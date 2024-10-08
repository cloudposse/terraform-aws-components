variable "region" {
  type        = string
  description = "AWS Region"
}

variable "callbacks" {
  type        = list(string)
  description = "Allowed Callback URLs"
  default     = []
}

variable "cross_origin_auth" {
  type        = bool
  description = "Whether this client can be used to make cross-origin authentication requests (true) or it is not allowed to make such requests (false)."
  default     = false
}

variable "allowed_origins" {
  type        = list(string)
  description = "Allowed Origins"
  default     = []
}

variable "web_origins" {
  type        = list(string)
  description = "Allowed Web Origins"
  default     = []
}

variable "grant_types" {
  type        = list(string)
  description = "Allowed Grant Types"
  default     = []
}

variable "logo_uri" {
  type        = string
  description = "Logo URI"
  default     = "https://cloudposse.com/wp-content/uploads/2017/07/CloudPosse2-TRANSAPRENT.png"
}

variable "app_type" {
  type        = string
  description = "Auth0 Application Type"
  default     = "regular_web"
}

variable "oidc_conformant" {
  type        = bool
  description = "OIDC Conformant"
  default     = true
}

variable "sso" {
  type        = bool
  description = "Single Sign-On for the Auth0 app"
  default     = true
}

variable "jwt_lifetime_in_seconds" {
  type        = number
  description = "JWT Lifetime in Seconds"
  default     = 36000
}

variable "jwt_alg" {
  type        = string
  description = "JWT Algorithm"
  default     = "RS256"
}

variable "ssm_base_path" {
  type        = string
  description = "The base path for the SSM parameters. If not defined, this is set to the module context ID. This is also required when `var.enabled` is set to `false`"
  default     = ""
}

variable "authentication_method" {
  type        = string
  description = "The authentication method for the client credentials"
  default     = "client_secret_post"
}
