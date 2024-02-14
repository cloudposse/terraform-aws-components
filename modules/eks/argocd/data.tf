locals {
  oidc_client_id     = local.oidc_enabled ? data.aws_ssm_parameter.oidc_client_id[0].value : ""
  oidc_client_secret = local.oidc_enabled ? data.aws_ssm_parameter.oidc_client_secret[0].value : ""
}

# NOTE: OIDC parameters are global, hence why they use a separate AWS provider

#
# These variables are depreciated but should not yet be removed. Future iterations of this component will delete these variables
#

data "aws_ssm_parameter" "oidc_client_id" {
  count           = local.oidc_enabled_count
  name            = var.ssm_oidc_client_id
  with_decryption = true

  provider = aws.config_secrets
}

data "aws_ssm_parameter" "oidc_client_secret" {
  count           = local.oidc_enabled_count
  name            = var.ssm_oidc_client_secret
  with_decryption = true

  provider = aws.config_secrets
}

data "aws_ssm_parameter" "github_deploy_key" {
  for_each = local.enabled ? var.argocd_repositories : {}

  name = local.enabled ? format(
    module.argocd_repo[each.key].outputs.deploy_keys_ssm_path_format,
    format(
      "${module.this.tenant != null ? "%[1]s/" : ""}%[2]s-%[3]s${length(module.this.attributes) > 0 ? "-%[4]s" : "%[4]s"}",
      module.this.tenant,
      module.this.environment,
      module.this.stage,
      join("-", module.this.attributes)
    )
  ) : null

  with_decryption = true

  provider = aws.config_secrets
}
