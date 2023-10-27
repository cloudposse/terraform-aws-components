variable "github_default_notifications_enabled" {
  type        = bool
  default     = true
  description = "Enable default GitHub commit statuses notifications (required for CD sync mode)"
}

variable "notifications_templates" {
  description = <<-EOT
  Notification Templates to configure.

  See: https://argocd-notifications.readthedocs.io/en/stable/templates/
  See: [Example value in argocd-notifications Helm Chart](https://github.com/argoproj/argo-helm/blob/a0a74fb43d147073e41aadc3d88660b312d6d638/charts/argocd-notifications/values.yaml#L158)
  EOT

  type = map(object({
    message = string
    alertmanager = optional(object({
      labels       = map(string)
      annotations  = map(string)
      generatorURL = string
    }))
    webhook = optional(map(
      object({
        method = optional(string)
        path   = optional(string)
        body   = optional(string)
      })
    ))
  }))

  default = {}
}

variable "notifications_triggers" {
  description = <<-EOT
  Notification Triggers to configure.

  See: https://argocd-notifications.readthedocs.io/en/stable/triggers/
  See: [Example value in argocd-notifications Helm Chart](https://github.com/argoproj/argo-helm/blob/a0a74fb43d147073e41aadc3d88660b312d6d638/charts/argocd-notifications/values.yaml#L352)
  EOT

  type = map(list(
    object({
      oncePer = optional(string)
      send    = list(string)
      when    = string
    })
  ))

  default = {}
}

variable "notifications_notifiers" {
  type = object({
    ssm_path_prefix = optional(string, "/argocd/notifications/notifiers")
    # service.webhook.<webhook-name>:
    webhook = optional(map(
      object({
        url = string
        headers = optional(list(
          object({
            name  = string
            value = string
          })
        ), [])
        basicAuth = optional(object({
          username = string
          password = string
        }))
        insecureSkipVerify = optional(bool, false)
      })
    ))
  })
  description = <<-EOT
  Notification Triggers to configure.

  See: https://argocd-notifications.readthedocs.io/en/stable/triggers/
  See: [Example value in argocd-notifications Helm Chart](https://github.com/argoproj/argo-helm/blob/a0a74fb43d147073e41aadc3d88660b312d6d638/charts/argocd-notifications/values.yaml#L352)
  EOT
  default     = {}
}
