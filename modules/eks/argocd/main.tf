locals {
  enabled            = module.this.enabled
  count_enabled      = local.enabled ? 1 : 0
  oidc_enabled       = local.enabled && var.oidc_enabled
  oidc_enabled_count = local.oidc_enabled ? 1 : 0
  saml_enabled       = local.enabled && var.saml_enabled
  argocd_repositories = local.enabled ? {
    for k, v in var.argocd_repositories : k => {
      clone_url         = module.argocd_repo[k].outputs.repository_ssh_clone_url
      github_deploy_key = data.aws_ssm_parameter.github_deploy_key[k].value
    }
  } : {}
  credential_templates = flatten([
    for k, v in local.argocd_repositories : [
      {
        name  = "configs.credentialTemplates.${k}.url"
        value = v.clone_url
        type  = "string"
      },
      {
        name  = "configs.credentialTemplates.${k}.sshPrivateKey"
        value = v.github_deploy_key
        type  = "string"
      },
    ]
  ])
  kubernetes_namespace              = "argocd"
  regional_service_discovery_domain = "${module.this.environment}.${module.dns_gbl_delegated.outputs.default_domain_name}"
  host                              = var.host != "" ? var.host : format("%s.%s", var.alb_name, local.regional_service_discovery_domain)
  enable_argo_workflows_auth        = local.saml_enabled && var.argo_enable_workflows_auth
  enable_argo_workflows_auth_count  = local.enable_argo_workflows_auth ? 1 : 0
  argo_workflows_host               = "${var.argo_workflows_name}.${local.regional_service_discovery_domain}"

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
    server : {
      config : {
        "dex.config" = join("\n", [
          local.dex_config_connectors,
          local.dex_config_static_clients,
        ])
      }
    }
  } : {}

  dex_config_connectors = <<-EOT
    connectors:
      - type: saml
        id: okta
        name: Okta
        config:
          ssoURL: ${local.saml_sso_url}
          caData: ${local.saml_ca}
          redirectURI: https://${local.host}/api/dex/callback
          usernameAttr: email
          emailAttr: email
          groupsAttr: group
    EOT

  dex_config_static_clients = local.enable_argo_workflows_auth ? (<<-EOT
    staticClients:
      - id: ${data.sops_file.argo_workflows_sops[0].data["spec.secretTemplates.0.stringData.client-id"]}
        name: Argo Workflow
        secretEnv: ARGO_WORKFLOWS_SSO_CLIENT_SECRET
        redirectURIs:
          - https://${local.argo_workflows_host}/oauth2/callback
    EOT
  ) : ""

  post_render_script = local.enable_argo_workflows_auth ? "./resources/kustomize/post-render.sh" : null
  kustomize_files_values = local.enable_argo_workflows_auth ? {
    __ignore = {
      kustomize_files = { for f in fileset("./resources/kustomize", "[^_]*.{sh,yaml}") : f => filesha256("./resources/kustomize/${f}") }
    }
  } : {}
}

module "argo-workflows-sops" {
  source  = "../sops-secrets-operator/modules/sops_manifest"
  enabled = local.enable_argo_workflows_auth

  context              = module.introspection.context
  kubernetes_namespace = var.kubernetes_namespace
  sops_directory       = abspath("./resources")
  sops_file_prefix     = "argo-workflows-keys"
}

module "argocd-notifications-sops" {
  source = "../sops-secrets-operator/modules/sops_manifest"

  context              = module.introspection.context
  kubernetes_namespace = var.kubernetes_namespace
  sops_directory       = abspath("./resources")
  sops_file_name       = "argocd-notifications-secret.sops.yaml"
}

module "argocd" {
  source  = "cloudposse/helm-release/aws"
  version = "0.3.0"

  name                   = "" # avoids hitting length restrictions on IAM Role names
  chart                  = var.chart
  repository             = var.chart_repository
  description            = var.chart_description
  chart_version          = var.chart_version
  kubernetes_namespace   = var.kubernetes_namespace
  create_namespace       = var.create_namespace
  wait                   = var.wait
  atomic                 = var.atomic
  cleanup_on_fail        = var.cleanup_on_fail
  timeout                = var.timeout
  postrender_binary_path = local.post_render_script

  eks_cluster_oidc_issuer_url = module.eks.outputs.eks_cluster_identity_oidc_issuer

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
      "${path.module}/resources/argocd-values.tpl.yaml",
      {
        admin_enabled              = !(local.oidc_enabled || local.saml_enabled)
        alb_group_name             = var.alb_group_name
        alb_logs_bucket            = var.alb_logs_bucket
        alb_logs_prefix            = var.alb_logs_prefix
        alb_name                   = var.alb_name
        application_repos          = { for k, v in local.argocd_repositories : k => v.clone_url }
        argocd_host                = local.host
        cert_issuer                = var.certificate_issuer
        forecastle_enabled         = var.forecastle_enabled
        ingress_host               = local.host
        name                       = module.this.name
        oidc_enabled               = local.oidc_enabled
        oidc_rbac_scopes           = var.oidc_rbac_scopes
        organization               = var.github_organization
        saml_enabled               = local.saml_enabled
        saml_rbac_scopes           = var.saml_rbac_scopes
        rbac_policies              = var.argocd_rbac_policies
        rbac_groups                = var.argocd_rbac_groups
        enable_argo_workflows_auth = local.enable_argo_workflows_auth
      }
    ),
    # argocd-notifications specific settings
    templatefile(
      "${path.module}/resources/argocd-notifications-values.tpl.yaml",
      {
        argocd_host                   = "https://${local.host}/"
        slack_notifications_enabled   = var.slack_notifications_enabled
        slack_notifications_username  = var.slack_notifications_username
        slack_notifications_icon      = var.slack_notifications_icon
        github_notifications_enabled  = var.github_notifications_enabled
        datadog_notifications_enabled = var.datadog_notifications_enabled
      }
    ),
    yamlencode(
      {
        notifications = {
          templates = var.notifications_templates
        }
      }
    ),
    yamlencode(
      {
        notifications = {
          triggers = var.notifications_triggers
        }
      }
    ),
    yamlencode(merge(
      local.oidc_config_map,
      local.saml_config_map,
    )),
    yamlencode(local.kustomize_files_values),
    yamlencode(var.chart_values)
  ])

  context = module.introspection.context
}

module "argocd_apps" {
  source  = "cloudposse/helm-release/aws"
  version = "0.3.0"

  name                 = "" # avoids hitting length restrictions on IAM Role names
  chart                = var.argocd_apps_chart
  repository           = var.argocd_apps_chart_repository
  description          = var.argocd_apps_chart_description
  chart_version        = var.argocd_apps_chart_version
  kubernetes_namespace = var.kubernetes_namespace
  create_namespace     = var.create_namespace
  wait                 = var.wait
  atomic               = var.atomic
  cleanup_on_fail      = var.cleanup_on_fail
  timeout              = var.timeout

  values = compact([
    templatefile(
      "${path.module}/resources/argocd-apps-values.tpl.yaml",
      {
        application_repos = { for k, v in local.argocd_repositories : k => v.clone_url }
        create_namespaces = var.argocd_create_namespaces
        namespace         = local.kubernetes_namespace
        tenant            = module.this.tenant
        environment       = var.environment
        stage             = var.stage
      }
    ),
  ])

  depends_on = [
    module.argocd
  ]
}
