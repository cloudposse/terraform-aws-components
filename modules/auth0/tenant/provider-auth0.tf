locals {
  auth0_domain_ssm_path        = "/${module.this.id}/domain"
  auth0_client_id_ssm_path     = "/${module.this.id}/client_id"
  auth0_client_secret_ssm_path = "/${module.this.id}/client_secret"
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
  debug         = true
}
