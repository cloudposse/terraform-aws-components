variable "region" {
  type        = string
  description = "AWS Region"
}

variable "github_org_name" {
  type        = string
  description = "SSM parameter name format"
}

variable "github_app_installation_id" {
  type        = string
  description = "GitHub App Installation ID"
}

variable "github_app_id" {
  type        = string
  description = "GitHub App ID"
}

variable "parameter_store_private_key_path" {
  type        = string
  description = "Path to read the GitHub App private key from parameter store"
}

variable "parameter_store_token_path" {
  type        = string
  description = "Path to store the token in parameter store"
}
