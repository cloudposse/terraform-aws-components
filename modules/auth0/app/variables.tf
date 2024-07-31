variable "region" {
  type        = string
  description = "AWS Region"
}

variable "callbacks" {
  type        = list(string)
  description = "Allowed Callback URLs"
  default     = []
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
