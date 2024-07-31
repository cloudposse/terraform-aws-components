locals {
  auth0_domain_ssm_path        = local.enabled && length(var.provider_ssm_base_path) == 0 ? "/${module.this.id}/domain" : "/${var.provider_ssm_base_path}/domain"
  auth0_client_id_ssm_path     = local.enabled && length(var.provider_ssm_base_path) == 0 ? "/${module.this.id}/client_id" : "/${var.provider_ssm_base_path}/client_id"
  auth0_client_secret_ssm_path = local.enabled && length(var.provider_ssm_base_path) == 0 ? "/${module.this.id}/client_secret" : "/${var.provider_ssm_base_path}/client_secret"
}

variable "provider_ssm_base_path" {
  type        = string
  description = "The base path for the SSM parameters. If not defined, this is set to the module context ID. This is also required when `var.enabled` is set to `false`"
  default     = ""
}

variable "auth0_debug" {
  type        = bool
  description = "Enable debug mode for the Auth0 provider"
  default     = true
}

data "aws_ssm_parameter" "auth0_domain" {
  name = local.auth0_domain_ssm_path
}

data "aws_ssm_parameter" "auth0_client_id" {
  name = local.auth0_client_id_ssm_path
}

data "aws_ssm_parameter" "auth0_client_secret" {
  name = local.auth0_client_secret_ssm_path
}

provider "auth0" {
  domain        = data.aws_ssm_parameter.auth0_domain.value
  client_id     = data.aws_ssm_parameter.auth0_client_id.value
  client_secret = data.aws_ssm_parameter.auth0_client_secret.value
  debug         = var.auth0_debug
}
