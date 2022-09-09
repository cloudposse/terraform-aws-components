locals {
  github_token = local.enabled ? coalesce(var.github_token_override, data.aws_ssm_parameter.github_api_key[0].value) : ""
}

data "aws_ssm_parameter" "github_api_key" {
  count           = local.enabled ? 1 : 0
  name            = var.ssm_github_api_key
  with_decryption = true
}

data "aws_ssm_parameter" "private_deploy_keys" {
  for_each        = local.ssm_deploy_key_environments
  name            = format(var.ssm_github_deploy_key_format, each.key)
  with_decryption = true
}

data "aws_ssm_parameter" "public_deploy_keys" {
  for_each        = local.ssm_deploy_key_environments
  name            = "${format(var.ssm_github_deploy_key_format, each.key)}.pub"
  with_decryption = true
}

module "store_write" {
  count   = var.deploy_key_generation_enabled ? 1 : 0
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.8.3"

  parameter_write = [for k, v in local.environments :
    {
      name      = format(var.ssm_github_deploy_key_format, k)
      value     = tls_private_key.default[k].private_key_openssh
      type      = "SecureString"
      overwrite = true
    }
  ]

  context = module.introspection.context
}