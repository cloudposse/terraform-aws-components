variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "aws_region" {
  type = "string"
}

variable "accounts_enabled" {
  type        = "list"
  description = "Accounts to enable"
  default     = ["dev", "staging", "prod", "testing", "audit"]
}

variable "output_path" {
  type        = "string"
  default     = "./"
  description = "Base directory where files will be written"
}

variable "env_file" {
  type        = "string"
  description = "File to write the temporary bootstrap environment variable settings"
  default     = ".envrc"
}

variable "config_file" {
  type        = "string"
  description = "File to write the temporary bootstrap AWS config"
  default     = ".aws/config"
}

variable "credentials_file" {
  type        = "string"
  description = "File to write the temporary bootstrap AWS credentials"
  default     = ".aws/credentials"
}
