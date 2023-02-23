locals {
  kubernetes_host                   = local.enabled ? data.aws_eks_cluster.kubernetes[0].endpoint : ""
  kubernetes_token                  = local.enabled ? data.aws_eks_cluster_auth.kubernetes[0].token : ""
  kubernetes_cluster_ca_certificate = local.enabled ? base64decode(data.aws_eks_cluster.kubernetes[0].certificate_authority[0].data) : ""
  oidc_client_id                    = local.oidc_enabled ? data.aws_ssm_parameter.oidc_client_id[0].value : ""
  oidc_client_secret                = local.oidc_enabled ? data.aws_ssm_parameter.oidc_client_secret[0].value : ""

  #  saml_certificate = base64encode(format("-----BEGIN CERTIFICATE-----\n%s\n-----END CERTIFICATE-----", module.okta_saml_apps.outputs.certificates[var.saml_okta_app_name]))
  #
  #  saml_sso_url = sensitive(local.saml_enabled ? module.okta_saml_apps.outputs.sso_urls[var.saml_okta_app_name] : "")
  #  saml_ca      = sensitive(local.saml_enabled ? local.saml_certificate : "")
}

# NOTE: OIDC parameters are global, hence why they use a separate AWS provider

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

data "aws_eks_cluster" "kubernetes" {
  count = local.count_enabled
  name  = module.eks.outputs.eks_cluster_id
}

data "aws_eks_cluster_auth" "kubernetes" {
  count = local.count_enabled
  name  = module.eks.outputs.eks_cluster_id
}

data "aws_ssm_parameter" "github_deploy_key" {
  for_each = local.enabled ? var.argocd_repositories : {}

  name = local.enabled ? format(
    module.argocd_repo[each.key].outputs.deploy_keys_ssm_path_format,
    format(
      "${module.this.tenant != null ? "%[1]s/" : ""}%[2]s-%[3]s",
      module.this.tenant,
      module.this.environment,
      module.this.stage
    )
  ) : null
  with_decryption = true

  provider = aws.config_secrets
}
