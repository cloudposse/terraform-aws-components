variable "notifications_templates" {
  type = map(object({
    message = string
    alertmanager = optional(object({
      labels       = map(string)
      annotations  = map(string)
      generatorURL = string
    }))
    github = optional(object({
      status = object({
        state     = string
        label     = string
        targetURL = string
      })
    }))
  }))
  default     = {}
  description = <<-EOT
  Notification Templates to configure.

  See: https://argocd-notifications.readthedocs.io/en/stable/templates/
  See: [Example value in argocd-notifications Helm Chart](https://github.com/argoproj/argo-helm/blob/a0a74fb43d147073e41aadc3d88660b312d6d638/charts/argocd-notifications/values.yaml#L158)
  EOT
}

variable "notifications_triggers" {
  type = map(list(
    object({
      oncePer = optional(string)
      send    = list(string)
      when    = string
    })
  ))
  default     = {}
  description = <<-EOT
  Notification Triggers to configure.

  See: https://argocd-notifications.readthedocs.io/en/stable/triggers/
  See: [Example value in argocd-notifications Helm Chart](https://github.com/argoproj/argo-helm/blob/a0a74fb43d147073e41aadc3d88660b312d6d638/charts/argocd-notifications/values.yaml#L352)
  EOT
}

variable "notifications_notifiers" {
  type = object({
    ssm_path_prefix = optional(string, "/argocd/notifications/notifiers")
    service_github = optional(object({
      appID          = optional(number)
      installationID = optional(number)
      privateKey     = optional(string)
    }))
  })
  default     = {}
  description = <<-EOT
  Notification Triggers to configure.

  See: https://argocd-notifications.readthedocs.io/en/stable/triggers/
  See: [Example value in argocd-notifications Helm Chart](https://github.com/argoproj/argo-helm/blob/a0a74fb43d147073e41aadc3d88660b312d6d638/charts/argocd-notifications/values.yaml#L352)
  EOT
}


variable "notifications_default_triggers" {
  type        = map(list(string))
  default     = {}
  description = <<-EOT
  Default notification Triggers to configure.

  See: https://argo-cd.readthedocs.io/en/stable/operator-manual/notifications/triggers/#default-triggers
  See: [Example value in argocd-notifications Helm Chart](https://github.com/argoproj/argo-helm/blob/790438efebf423c2d56cb4b93471f4adb3fcd448/charts/argo-cd/values.yaml#L2841)
  EOT
}


variable "slack_notifications_enabled" {
  type        = bool
  default     = false
  description = "Whether or not to enable Slack notifications."
}

variable "slack_notifications_username" {
  type        = string
  default     = null
  description = "Custom username to use for Slack notifications."
}

variable "slack_notifications_icon" {
  type        = string
  default     = null
  description = "URI of custom image to use as the Slack notifications icon."
}

variable "github_notifications_enabled" {
  type        = bool
  default     = false
  description = "Whether or not to enable GitHub deployment and commit status notifications."
}

variable "datadog_notifications_enabled" {
  type        = bool
  default     = false
  description = "Whether or not to notify Datadog of deployments via the Datadog Events API."
}
