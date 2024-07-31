variable "region" {
  type        = string
  description = "AWS Region"
}

variable "friendly_name" {
  type        = string
  description = "The friendly name of the Auth0 tenant. If not provided, the module context ID will be used."
  default     = ""
}

variable "picture_url" {
  type        = string
  description = "The URL of the picture to be displayed in the Auth0 Universal Login page."
  default     = "https://cloudposse.com/wp-content/uploads/2017/07/CloudPosse2-TRANSAPRENT.png"
}

variable "support_email" {
  type        = string
  description = "The email address to be displayed in the Auth0 Universal Login page."
}

variable "support_url" {
  type        = string
  description = "The URL to be displayed in the Auth0 Universal Login page."
}

variable "allowed_logout_urls" {
  type        = list(string)
  description = "The URLs that Auth0 can redirect to after logout."
  default     = []
}

variable "idle_session_lifetime" {
  type        = number
  description = "The idle session lifetime in hours."
  default     = 72
}

variable "session_lifetime" {
  type        = number
  description = "The session lifetime in hours."
  default     = 168
}

variable "sandbox_version" {
  type        = string
  description = "The sandbox version."
  default     = "18"
}

variable "enabled_locales" {
  type        = list(string)
  description = "The enabled locales."
  default     = ["en"]
}

variable "default_redirection_uri" {
  type        = string
  description = "The default redirection URI."
  default     = ""
}

variable "disable_clickjack_protection_headers" {
  type        = bool
  description = "Whether to disable clickjack protection headers."
  default     = true
}

variable "enable_public_signup_user_exists_error" {
  type        = bool
  description = "Whether to enable public signup user exists error."
  default     = true
}

variable "use_scope_descriptions_for_consent" {
  type        = bool
  description = "Whether to use scope descriptions for consent."
  default     = false
}

variable "no_disclose_enterprise_connections" {
  type        = bool
  description = "Whether to disclose enterprise connections."
  default     = false
}

variable "disable_management_api_sms_obfuscation" {
  type        = bool
  description = "Whether to disable management API SMS obfuscation."
  default     = false
}

variable "disable_fields_map_fix" {
  type        = bool
  description = "Whether to disable fields map fix."
  default     = false
}

variable "session_cookie_mode" {
  type        = string
  description = "The session cookie mode."
  default     = "persistent"
}

variable "oidc_logout_prompt_enabled" {
  type        = bool
  description = "Whether the OIDC logout prompt is enabled."
  default     = false
}
