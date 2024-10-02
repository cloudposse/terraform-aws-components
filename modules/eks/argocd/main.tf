locals {
  enabled = module.this.enabled

  kubernetes_namespace = var.kubernetes_namespace
  oidc_enabled         = local.enabled && var.oidc_enabled
  oidc_enabled_count   = local.oidc_enabled ? 1 : 0
  saml_enabled         = local.enabled && var.saml_enabled
  argocd_repositories = local.enabled ? {
    for k, v in var.argocd_repositories : replace(k, "/", "-") => {
      clone_url         = module.argocd_repo[k].outputs.repository_ssh_clone_url
      github_deploy_key = data.aws_ssm_parameter.github_deploy_key[k].value
      repository        = module.argocd_repo[k].outputs.repository
    }
  } : {}

  credential_templates = flatten(concat([
    for k, v in local.argocd_repositories : [
      {
        name  = "configs.credentialTemplates.${k}.url"
        value = v.clone_url
        type  = "string"
      },
      {
        name  = "configs.credentialTemplates.${k}.sshPrivateKey"
        value = nonsensitive(v.github_deploy_key)
        type  = "string"
      },
    ]
    ],
    [
      for s, v in local.notifications_notifiers_ssm_configs : [
        for k, i in v : [
          {
            name  = "notifications.secret.items.${s}_${k}"
            value = i
            type  = "string"
          }
        ]
      ]
    ],
    local.github_webhook_enabled ? [
      {
        name  = "configs.secret.githubSecret"
        value = nonsensitive(local.webhook_github_secret)
        type  = "string"
      }
    ] : [],
    local.slack_notifications_enabled ? [
      {
        name  = "notifications.secret.items.slack-token"
        value = data.aws_ssm_parameter.slack_notifications[0].value
        type  = "string"
      }
    ] : []
  ))
  regional_service_discovery_domain = "${module.this.environment}.${module.dns_gbl_delegated.outputs.default_domain_name}"
  host                              = var.host != "" ? var.host : format("%s.%s", var.name, local.regional_service_discovery_domain)
  url                               = format("https://%s", local.host)

  oidc_config_map = local.oidc_enabled ? {
    server : {
      config : {
        "oidc.config" = <<-EOT
          name: ${var.oidc_name}
          issuer: ${var.oidc_issuer}
          clientID: ${local.oidc_client_id}
          clientSecret: ${local.oidc_client_secret}
          requestedScopes: ${var.oidc_requested_scopes}
          EOT
      }
    }
  } : {}

  saml_config_map = local.saml_enabled ? {
    configs : {
      params : {
        "dexserver.disable.tls" = true
      }
      cm : {
        "url" = local.url
        "dex.config" = join("\n", [
          local.dex_config_connectors
        ])
      }
    }
  } : {}

  dex_config_connectors = yamlencode({
    connectors = [
      for name, config in(local.enabled ? var.saml_sso_providers : {}) :
      {
        type = "saml"
        id   = "saml"
        name = name
        config = {
          ssoURL       = module.saml_sso_providers[name].outputs.url
          caData       = base64encode(format("-----BEGIN CERTIFICATE-----\n%s\n-----END CERTIFICATE-----", module.saml_sso_providers[name].outputs.ca))
          redirectURI  = format("https://%s/api/dex/callback", local.host)
          entityIssuer = format("https://%s/api/dex/callback", local.host)
          usernameAttr = module.saml_sso_providers[name].outputs.usernameAttr
          emailAttr    = module.saml_sso_providers[name].outputs.emailAttr
          groupsAttr   = module.saml_sso_providers[name].outputs.groupsAttr
          ssoIssuer    = module.saml_sso_providers[name].outputs.issuer
        }
      }
    ]
    }
  )
}

module "argocd" {
  source  = "cloudposse/helm-release/aws"
  version = "0.10.1"

  name                 = "argocd" # avoids hitting length restrictions on IAM Role names
  chart                = var.chart
  repository           = var.chart_repository
  description          = var.chart_description
  chart_version        = var.chart_version
  kubernetes_namespace = local.kubernetes_namespace
  create_namespace     = var.create_namespace
  wait                 = var.wait
  atomic               = var.atomic
  cleanup_on_fail      = var.cleanup_on_fail
  timeout              = var.timeout

  eks_cluster_oidc_issuer_url = replace(module.eks.outputs.eks_cluster_identity_oidc_issuer, "https://", "")

  service_account_name      = module.this.name
  service_account_namespace = var.kubernetes_namespace

  set_sensitive = local.credential_templates

  values = compact([
    # standard k8s object settings
    yamlencode({
      fullnameOverride = module.this.name,
      serviceAccount = {
        name = module.this.name
      },
      resources = var.resources
      rbac = {
        create = var.rbac_enabled
      }
    }),
    # argocd-specific settings
    templatefile(
      "${path.module}/resources/argocd-values.yaml.tpl",
      {
        admin_enabled       = var.admin_enabled
        anonymous_enabled   = var.anonymous_enabled
        alb_group_name      = var.alb_group_name == null ? "" : var.alb_group_name
        alb_logs_bucket     = var.alb_logs_bucket
        alb_logs_prefix     = var.alb_logs_prefix
        alb_name            = var.alb_name == null ? "" : var.alb_name
        application_repos   = { for k, v in local.argocd_repositories : k => v.clone_url }
        argocd_host         = local.host
        cert_issuer         = var.certificate_issuer
        forecastle_enabled  = var.forecastle_enabled
        ingress_host        = local.host
        name                = module.this.name
        oidc_enabled        = local.oidc_enabled
        oidc_rbac_scopes    = var.oidc_rbac_scopes
        saml_enabled        = local.saml_enabled
        saml_rbac_scopes    = var.saml_rbac_scopes
        service_type        = var.service_type
        rbac_default_policy = var.argocd_rbac_default_policy
        rbac_policies       = var.argocd_rbac_policies
        rbac_groups         = var.argocd_rbac_groups
      }
    ),
    # argocd-notifications specific settings
    templatefile(
      "${path.module}/resources/argocd-notifications-values.yaml.tpl",
      {
        argocd_host  = "https://${local.host}"
        configs-hash = md5(jsonencode(local.notifications))
        secrets-hash = md5(jsonencode(local.notifications_notifiers_ssm_configs))
      }
    ),
    yamlencode(local.notifications),
    yamlencode(merge(
      local.oidc_config_map,
      local.saml_config_map,
    )),
    yamlencode(var.chart_values)
  ])

  context = module.this.context
}

data "kubernetes_resources" "crd" {
  api_version    = "apiextensions.k8s.io/v1"
  kind           = "CustomResourceDefinition"
  field_selector = "metadata.name==applications.argoproj.io"
}

module "argocd_apps" {
  source  = "cloudposse/helm-release/aws"
  version = "0.10.1"

  name                        = "" # avoids hitting length restrictions on IAM Role names
  chart                       = var.argocd_apps_chart
  repository                  = var.argocd_apps_chart_repository
  description                 = var.argocd_apps_chart_description
  chart_version               = var.argocd_apps_chart_version
  kubernetes_namespace        = var.kubernetes_namespace
  create_namespace            = var.create_namespace
  wait                        = var.wait
  atomic                      = var.atomic
  cleanup_on_fail             = var.cleanup_on_fail
  timeout                     = var.timeout
  enabled                     = local.enabled && var.argocd_apps_enabled && length(data.kubernetes_resources.crd.objects) > 0
  eks_cluster_oidc_issuer_url = replace(module.eks.outputs.eks_cluster_identity_oidc_issuer, "https://", "")
  values = compact([
    templatefile(
      "${path.module}/resources/argocd-apps-values.yaml.tpl",
      {
        application_repos = { for k, v in local.argocd_repositories : k => v.clone_url }
        create_namespaces = var.argocd_create_namespaces
        namespace         = local.kubernetes_namespace
        tenant            = module.this.tenant
        environment       = var.environment
        stage             = var.stage
        attributes        = var.attributes
      }
    ),
    yamlencode(var.argocd_apps_chart_values)
  ])

  depends_on = [
    module.argocd
  ]
}
