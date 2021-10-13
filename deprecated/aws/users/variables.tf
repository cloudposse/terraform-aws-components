variable "aws_assume_role_arn" {}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  type        = "string"
  description = "Application or solution name (e.g. `app`)"
  default     = "terraform"
}

variable "smtp_username" {
  description = "Username to authenticate with the SMTP server"
  type        = "string"
  default     = ""
}

variable "smtp_password" {
  description = "Password to authenticate with the SMTP server"
  type        = "string"
  default     = ""
}

variable "smtp_host" {
  description = "SMTP Host"
  default     = ""
}

variable "smtp_port" {
  description = "SMTP Port"
  default     = "587"
}

variable "accounts_enabled" {
  type        = "list"
  description = "Accounts to enable"
  default     = ["dev", "staging", "prod", "testing", "audit"]
}
