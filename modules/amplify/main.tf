locals {
  enabled = module.this.enabled

  domain_config = var.domain_config != null ? {
    domain_name            = coalesce(lookup(var.domain_config, "domain_name", null), module.dns_delegated.outputs.default_domain_name)
    enable_auto_sub_domain = lookup(var.domain_config, "enable_auto_sub_domain", false)
    wait_for_verification  = lookup(var.domain_config, "wait_for_verification", false)
    sub_domain             = lookup(var.domain_config, "sub_domain")
  } : null
}

# Read the GitHub PAT from SSM
data "aws_ssm_parameter" "github_pat" {
  count = local.enabled ? 1 : 0

  name            = var.github_personal_access_token_secret_path
  with_decryption = true
}

module "amplify_app" {
  source  = "cloudposse/amplify-app/aws"
  version = "0.2.1"

  description                   = var.description
  repository                    = var.repository
  platform                      = var.platform
  access_token                  = one(data.aws_ssm_parameter.github_pat[*].value)
  oauth_token                   = var.oauth_token
  auto_branch_creation_config   = var.auto_branch_creation_config
  auto_branch_creation_patterns = var.auto_branch_creation_patterns
  basic_auth_credentials        = var.basic_auth_credentials
  build_spec                    = var.build_spec
  enable_auto_branch_creation   = var.enable_auto_branch_creation
  enable_basic_auth             = var.enable_basic_auth
  enable_branch_auto_build      = var.enable_branch_auto_build
  enable_branch_auto_deletion   = var.enable_branch_auto_deletion
  environment_variables         = var.environment_variables
  custom_rules                  = var.custom_rules
  iam_service_role_enabled      = var.iam_service_role_enabled
  iam_service_role_arn          = var.iam_service_role_arn
  iam_service_role_actions      = var.iam_service_role_actions
  environments                  = var.environments
  domain_config                 = local.domain_config

  context = module.this.context
}
