locals {
  enabled              = module.this.enabled
  kubernetes_namespace = var.kubernetes_namespace
  count_enabled        = local.enabled ? 1 : 0
  oidc_enabled         = local.enabled && var.oidc_enabled
  oidc_enabled_count   = local.oidc_enabled ? 1 : 0
  saml_enabled         = local.enabled && var.saml_enabled
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
  regional_service_discovery_domain = "${module.this.environment}.${module.dns_gbl_delegated.outputs.default_domain_name}"
  host                              = var.host != "" ? var.host : format("%s.%s", coalesce(var.alb_name, var.name), local.regional_service_discovery_domain)
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
    configs : {
      params : {
        "dexserver.disable.tls" = true
      }
      cm : {
        "url" = "https://${local.host}"
        "dex.config" = join("\n", [
          local.dex_config_connectors
        ])
      }
    }
  } : {}

  dex_config_connectors = yamlencode({
    connectors = [for name, config in(local.enabled ? var.saml_sso_providers : {}) :
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
  })

  post_render_script = local.enable_argo_workflows_auth ? "./resources/kustomize/post-render.sh" : null
  kustomize_files_values = local.enable_argo_workflows_auth ? {
    __ignore = {
      kustomize_files = { for f in fileset("./resources/kustomize", "[^_]*.{sh,yaml}") : f => filesha256("./resources/kustomize/${f}") }
    }
  } : {}
}

data "aws_ssm_parameters_by_path" "argocd_notifications" {
  for_each        = local.notifications_notifiers_ssm_path
  path            = each.value
  with_decryption = true
}

locals {
  notifications_notifiers_ssm_path = { for key, value in var.notifications_notifiers :
    key => format("%s/%s/", var.notifications_notifiers.ssm_path_prefix, key)
  }

  notifications_notifiers_ssm_configs = { for key, value in data.aws_ssm_parameters_by_path.argocd_notifications :
    key => nonsensitive(zipmap(
      [for name in value.names : trimprefix(name, local.notifications_notifiers_ssm_path[key])],
      value.values
    ))
  }

  notifications_notifiers_variables = {
    for key, value in var.notifications_notifiers :
    key => { for param_name, param_value in value : param_name => param_value if param_value != null }
    if key != "ssm_path_prefix"
  }

  notifications_notifiers = {
    for key, value in local.notifications_notifiers_variables :
    replace(key, "_", ".") => yamlencode(merge(local.notifications_notifiers_ssm_configs[key], value))
  }
}

module "argocd" {
  source  = "cloudposse/helm-release/aws"
  version = "0.3.0"

  name                   = "argocd" # avoids hitting length restrictions on IAM Role names
  chart                  = var.chart
  repository             = var.chart_repository
  description            = var.chart_description
  chart_version          = var.chart_version
  kubernetes_namespace   = local.kubernetes_namespace
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
      "${path.module}/resources/argocd-values.yaml.tpl",
      {
        admin_enabled              = var.admin_enabled
        alb_group_name             = var.alb_group_name == null ? "" : var.alb_group_name
        alb_logs_bucket            = var.alb_logs_bucket
        alb_logs_prefix            = var.alb_logs_prefix
        alb_name                   = var.alb_name == null ? "" : var.alb_name
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
        rbac_default_policy        = var.argocd_rbac_default_policy
        rbac_policies              = var.argocd_rbac_policies
        rbac_groups                = var.argocd_rbac_groups
        enable_argo_workflows_auth = local.enable_argo_workflows_auth
      }
    ),
    # argocd-notifications specific settings
    templatefile(
      "${path.module}/resources/argocd-notifications-values.yaml.tpl",
      {
        argocd_host                   = "https://${local.host}"
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
          templates = { for key, value in var.notifications_templates : replace(key, "_", ".") => yamlencode(value) }
        }
      }
    ),
    yamlencode(
      {
        notifications = {
          triggers = { for key, value in var.notifications_triggers :
            replace(key, "_", ".") => yamlencode(value)
          }
        }
      }
    ),
    yamlencode(
      {
        notifications = {
          notifiers = local.notifications_notifiers
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

  context = module.this.context
}

data "kubernetes_resources" "crd" {
  api_version    = "apiextensions.k8s.io/v1"
  kind           = "CustomResourceDefinition"
  field_selector = "metadata.name==applications.argoproj.io"
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
  enabled              = local.enabled && var.argocd_apps_enabled && length(data.kubernetes_resources.crd.objects) > 0
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
      }
    ),
  ])

  depends_on = [
    module.argocd
  ]
}
