locals {
  enabled = module.this.enabled
}

module "github_action_token_rotator" {
  count = local.enabled ? 1 : 0

  source  = "cloudposse/github-action-token-rotator/aws"
  version = "0.1.0"

  parameter_store_token_path       = var.parameter_store_token_path
  parameter_store_private_key_path = var.parameter_store_private_key_path
  github_app_id                    = var.github_app_id
  github_app_installation_id       = var.github_app_installation_id
  github_org                       = var.github_org_name

  # this is to help shrink the size of the name to be < 64 for lambda IAM role
  function_name = "ghRunnerTokenRotator"

  context = module.this.context
}
