data "aws_ssm_parameters_by_path" "argocd_notifications" {
  for_each        = local.notifications_notifiers_ssm_path
  path            = each.value
  with_decryption = true
}

locals {
  github_default_notifications_enabled = local.enabled && var.github_default_notifications_enabled

  notification_default_notifier_github_commot_status = {
    url     = "https://api.github.com"
    headers = [
      {
        name  = "Authorization"
        value = "token $common_github-token"
      }
    ]
  }

  notification_default_notifiers = local.github_default_notifications_enabled ?  {
    webhook = {
      app-repo-github-commit-status    = local.notification_default_notifier_github_commot_status
      argocd-repo-github-commit-status = local.notification_default_notifier_github_commot_status
    }
  } : {}

  notifications_notifiers = merge(var.notifications_notifiers, local.notification_default_notifiers)

  ## Get list of notifiers services
  notifications_notifiers_variables = merge(
    {
      for key, value in local.notifications_notifiers :
      key => {for param_name, param_value in value : param_name => param_value if param_value != null}
      if key != "ssm_path_prefix" && key != "webhook"
    },
    {
      for key, value in coalesce(local.notifications_notifiers.webhook, {}) :
      format("webhook_%s", key) =>
      {for param_name, param_value in value : param_name => param_value if param_value != null}
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
}

locals {
  notifications_template_github_commit_status = {
    method = "POST"
    body   = {
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

  notifications_default_templates = local.github_default_notifications_enabled ? {
    app-deploy-succeded = {
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
  } : {}

  notifications_templates = merge(var.notifications_templates, local.notifications_default_templates)
}

locals {
  notifications_default_triggers = local.github_default_notifications_enabled ? {
    on-deploy-started = [
      {
        when    = "app.status.operationState.phase in ['Running'] or ( app.status.operationState.phase == 'Succeeded' and app.status.health.status == 'Progressing' )"
        oncePer = "app.status.sync.revision"
        send    = ["app-deploy-started"]
      }
    ],
    on-deploy-succeded = [
      {
        when    = "app.status.operationState.phase == 'Succeeded' and app.status.health.status == 'Healthy'"
        oncePer = "app.status.sync.revision"
        send    = ["app-deploy-succeded"]
      }
    ],
    on-deploy-failed = [
      {
        when    = "app.status.operationState.phase in ['Error', 'Failed' ] or ( app.status.operationState.phase == 'Succeeded' and app.status.health.status == 'Degraded' )"
        oncePer = "app.status.sync.revision"
        send    = ["app-deploy-failed"]
      }
    ]
  } : {}

  notifications_triggers = merge(var.notifications_triggers, local.notifications_default_triggers)
}

locals {
  notifications = {
    notifications = {
      templates = {for key, value in local.notifications_templates : format("template.%s", key) => yamlencode(value)}
      triggers  = {for key, value in local.notifications_triggers : format("trigger.%s", key) => yamlencode(value)}
      notifiers = {
        for key, value in local.notifications_notifiers_variables :
        format("service.%s", replace(key, "_", ".")) =>
        yamlencode(merge(local.notifications_notifiers_ssm_configs_keys[key], value))
      }
    }
  }
}

