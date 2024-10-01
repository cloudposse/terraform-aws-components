data "aws_ssm_parameters_by_path" "argocd_notifications" {
  for_each        = local.notifications_notifiers_ssm_path
  path            = each.value
  with_decryption = true
}

data "aws_ssm_parameter" "slack_notifications" {
  provider = aws.config_secrets
  count    = local.slack_notifications_enabled ? 1 : 0

  name            = var.slack_notifications.token_ssm_path
  with_decryption = true
}

module "notifications_templates" {
  source  = "cloudposse/config/yaml//modules/deepmerge"
  version = "1.0.2"

  count = local.enabled ? 1 : 0

  maps = [
    var.notifications_templates,
    local.github_notifications_enabled ? {
      app-deploy-succeeded = {
        message = "Application {{ .app.metadata.name }} is now running new version of deployments manifests."
        webhook = {
          app-repo-github-commit-status = {
            for k, v in local.notifications_template_app_github_commit_status :
            k => k == "body" ? jsonencode(merge(v, { state = "success" })) : tostring(v)
          }
          argocd-repo-github-commit-status = {
            for k, v in local.notifications_template_argocd_repo_github_commit_status :
            k => k == "body" ? jsonencode(merge(v, { state = "success" })) : tostring(v)
          }
        }
      }
      app-deploy-started = {
        message = "Application {{ .app.metadata.name }} is now running new version of deployments manifests."
        webhook = {
          app-repo-github-commit-status = {
            for k, v in local.notifications_template_app_github_commit_status :
            k => k == "body" ? jsonencode(merge(v, { state = "pending" })) : tostring(v)
          }
          argocd-repo-github-commit-status = {
            for k, v in local.notifications_template_argocd_repo_github_commit_status :
            k => k == "body" ? jsonencode(merge(v, { state = "pending" })) : tostring(v)
          }
        }
      }
      app-deploy-failed = {
        message = "Application {{ .app.metadata.name }} failed deploying new version."
        webhook = {
          app-repo-github-commit-status = {
            for k, v in local.notifications_template_app_github_commit_status :
            k => k == "body" ? jsonencode(merge(v, { state = "error" })) : tostring(v)
          }
          argocd-repo-github-commit-status = {
            for k, v in local.notifications_template_argocd_repo_github_commit_status :
            k => k == "body" ? jsonencode(merge(v, { state = "error" })) : tostring(v)
          }
        }
      }
    } : {},
    local.slack_notifications_enabled ? {
      app-created = {
        message = "Application {{ .app.metadata.name }} has been created."
        slack = {
          attachments = templatefile("${path.module}/resources/argocd-slack-message.tpl",
            {
              color = "#00ff00"
            }
          )
        }
      },
      app-deleted = {
        message = "Application {{ .app.metadata.name }} was deleted."
        slack = {
          attachments = templatefile("${path.module}/resources/argocd-slack-message.tpl",
            {
              color = "#FFA500"
            }
          )
        }
      },
      app-success = {
        message = "Application {{ .app.metadata.name }} deployment was successful!"
        slack = {
          attachments = templatefile("${path.module}/resources/argocd-slack-message.tpl",
            {
              color = "#00ff00"
            }
          )
        }
      },
      app-failure = {
        message = "Application {{ .app.metadata.name }} deployment failed!"
        slack = {
          attachments = templatefile("${path.module}/resources/argocd-slack-message.tpl",
            {
              color = "#FF0000"
            }
          )
        }
      },
      app-started = {
        message = "Application {{ .app.metadata.name }} started deployment..."
        slack = {
          attachments = templatefile("${path.module}/resources/argocd-slack-message.tpl",
            {
              color = "#0000ff"
            }
          )
        }
      },
      app-health-degraded = {
        message = "Application {{ .app.metadata.name }} health has degraded!"
        slack = {
          attachments = templatefile("${path.module}/resources/argocd-slack-message.tpl",
            {
              color = "#FF0000"
            }
          )
        }
      }
    } : {}
  ]
}

module "notifications_notifiers" {
  source  = "cloudposse/config/yaml//modules/deepmerge"
  version = "1.0.2"

  count = local.enabled ? 1 : 0

  maps = [
    var.notifications_notifiers,
    local.github_notifications_enabled ? {
      webhook = {
        app-repo-github-commit-status    = local.notification_default_notifier_github_commit_status
        argocd-repo-github-commit-status = local.notification_default_notifier_github_commit_status
      }
    } : {},
    local.slack_notifications_enabled ? {
      slack = local.notification_slack_service
    } : {}
  ]
}

locals {
  github_notifications_enabled = local.enabled && var.github_default_notifications_enabled
  slack_notifications_enabled  = local.enabled && var.slack_notifications_enabled

  notification_default_notifier_github_commit_status = {
    url = "https://api.github.com"
    headers = [
      {
        name  = "Authorization"
        value = "token $common_github-token"
      }
    ]
    insecureSkipVerify = false
  }

  notification_slack_service = {
    apiURL   = var.slack_notifications.api_url
    token    = "$slack-token"
    username = var.slack_notifications.username
    icon     = var.slack_notifications.icon
  }

  notifications_notifiers = jsondecode(local.enabled ? jsonencode(module.notifications_notifiers[0].merged) : jsonencode({}))

  ## Get list of notifiers services
  notifications_notifiers_variables = merge(
    {
      for key, value in local.notifications_notifiers :
      key => { for param_name, param_value in value : param_name => param_value if param_value != null }
      if key != "ssm_path_prefix" && key != "webhook"
    },
    {
      for key, value in coalesce(local.notifications_notifiers.webhook, {}) :
      format("webhook_%s", key) =>
      { for param_name, param_value in value : param_name => param_value if param_value != null }
    }
  )

  ## Get paths to read configs for each notifier service
  notifications_notifiers_ssm_path = merge(
    {
      for key, value in local.notifications_notifiers_variables :
      key => format("%s/%s/", local.notifications_notifiers.ssm_path_prefix, key)
    },
    {
      common = format("%s/common/", local.notifications_notifiers.ssm_path_prefix)
    },
  )

  ## Read SSM secrets into object for each notifier service
  notifications_notifiers_ssm_configs = {
    for key, value in data.aws_ssm_parameters_by_path.argocd_notifications :
    key => zipmap(
      [for name in value.names : trimprefix(name, local.notifications_notifiers_ssm_path[key])],
      nonsensitive(value.values)
    )
  }

  ## Define notifier service object with placeholders as values. This is ArgoCD convention
  notifications_notifiers_ssm_configs_keys = {
    for key, value in data.aws_ssm_parameters_by_path.argocd_notifications :
    key => zipmap(
      [for name in value.names : trimprefix(name, local.notifications_notifiers_ssm_path[key])],
      [for name in value.names : format("$%s_%s", key, trimprefix(name, local.notifications_notifiers_ssm_path[key]))]
    )
  }

  notifications_template_github_commit_status = {
    method = "POST"
    body = {
      description = "ArgoCD"
      target_url  = "{{.context.argocdUrl}}/applications/{{.app.metadata.name}}"
      context     = "continuous-delivery/{{.app.metadata.name}}"
    }
  }

  notifications_template_app_github_commit_status = merge(local.notifications_template_github_commit_status, {
    path = "/repos/{{call .repo.FullNameByRepoURL .app.metadata.annotations.app_repository}}/statuses/{{.app.metadata.annotations.app_commit}}"
  })

  notifications_template_argocd_repo_github_commit_status = merge(local.notifications_template_github_commit_status, {
    path = "/repos/{{call .repo.FullNameByRepoURL .app.spec.source.repoURL}}/statuses/{{.app.status.operationState.operation.sync.revision}}"
  })

  notifications_templates = jsondecode(local.enabled ? jsonencode(module.notifications_templates[0].merged) : jsonencode({}))

  notifications_default_triggers = merge(local.github_notifications_enabled ? {
    on-deploy-started = [
      {
        when    = "app.status.operationState.phase in ['Running'] or ( app.status.operationState.phase == 'Succeeded' and app.status.health.status == 'Progressing' )"
        oncePer = "app.status.sync.revision"
        send    = ["app-deploy-started"]
      }
    ],
    on-deploy-succeeded = [
      {
        when    = "app.status.operationState.phase == 'Succeeded' and app.status.health.status == 'Healthy'"
        oncePer = "app.status.sync.revision"
        send    = ["app-deploy-succeeded"]
      }
    ],
    on-deploy-failed = [
      {
        when    = "app.status.operationState.phase in ['Error', 'Failed' ] or ( app.status.operationState.phase == 'Succeeded' and app.status.health.status == 'Degraded' )"
        oncePer = "app.status.sync.revision"
        send    = ["app-deploy-failed"]
      }
    ]
    } : {},
    local.slack_notifications_enabled ? {
      # Full catalog of notification triggers as default
      # https://github.com/argoproj/argo-cd/tree/master/notifications_catalog/triggers
      on-created = [
        {
          when    = "true"
          send    = ["app-created"]
          oncePer = "app.metadata.name"
        }
      ],
      on-deleted = [
        {
          when    = "app.metadata.deletionTimestamp != nil"
          send    = ["app-deleted"]
          oncePer = "app.metadata.deletionTimestamp"
        }
      ],
      on-success = [
        {
          when    = "app.status.operationState != nil and app.status.operationState.phase in ['Succeeded'] and app.status.health.status == 'Healthy'"
          send    = ["app-success"]
          oncePer = "app.status.operationState?.syncResult?.revision"
        }
      ],
      on-failure = [
        {
          when    = "app.status.operationState != nil and (app.status.operationState.phase in ['Error', 'Failed'] or app.status.sync.status == 'Unknown')"
          send    = ["app-failure"]
          oncePer = "app.status.operationState?.syncResult?.revision"
        }
      ],
      on-health-degraded = [
        {
          when    = "app.status.health.status == 'Degraded'"
          send    = ["app-health-degraded"]
          oncePer = "app.status.operationState?.syncResult?.revision"
        }
      ],
      on-started = [
        {
          when    = "app.status.operationState != nil and app.status.operationState.phase in ['Running']"
          send    = ["app-started"]
          oncePer = "app.status.operationState?.syncResult?.revision"
        }
      ]
    } : {}
  )

  notifications_triggers = merge(var.notifications_triggers, local.notifications_default_triggers)

  notifications = {
    notifications = {
      templates = { for key, value in local.notifications_templates : format("template.%s", key) => yamlencode(value) }
      triggers  = { for key, value in local.notifications_triggers : format("trigger.%s", key) => yamlencode(value) }
      notifiers = {
        for key, value in local.notifications_notifiers_variables :
        format("service.%s", replace(key, "_", ".")) =>
        yamlencode(merge(local.notifications_notifiers_ssm_configs_keys[key], value))
      }
    }
  }
}
