variable "region" {
  type        = string
  description = "AWS Region"
}

variable "ssm_path_prefix" {
  type        = string
  description = "Top level SSM path prefix (without leading or trailing slash)"
}

variable "usernameAttr" {
  type        = string
  description = "User name attribute"
  default     = null
}

variable "emailAttr" {
  type        = string
  description = "Email attribute"
  default     = null
}

variable "groupsAttr" {
  type        = string
  description = "Group attribute"
  default     = null
}
