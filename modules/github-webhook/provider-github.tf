variable "github_base_url" {
  type        = string
  description = "This is the target GitHub base API endpoint. Providing a value is a requirement when working with GitHub Enterprise. It is optional to provide this value and it can also be sourced from the `GITHUB_BASE_URL` environment variable. The value must end with a slash, for example: `https://terraformtesting-ghe.westus.cloudapp.azure.com/`"
  default     = null
}

variable "ssm_github_api_key" {
  type        = string
  description = "SSM path to the GitHub API key"
  default     = "/argocd/github/api_key"
}

variable "github_token_override" {
  type        = string
  description = "Use the value of this variable as the GitHub token instead of reading it from SSM"
  default     = null
}

locals {
  github_token = local.enabled ? coalesce(var.github_token_override, try(data.aws_ssm_parameter.github_api_key[0].value, null)) : ""
}

data "aws_ssm_parameter" "github_api_key" {
  count           = local.enabled ? 1 : 0
  name            = var.ssm_github_api_key
  with_decryption = true
}

provider "github" {
  base_url = local.enabled ? var.github_base_url : null
  owner    = local.enabled ? var.github_organization : null
  token    = local.enabled ? local.github_token : null
}
