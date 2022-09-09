variable "notifications_templates" {
  type        = map(any)
  description = <<-EOT
  Notification Templates to configure.

  See: https://argocd-notifications.readthedocs.io/en/stable/templates/
  See: [Example value in argocd-notifications Helm Chart](https://github.com/argoproj/argo-helm/blob/a0a74fb43d147073e41aadc3d88660b312d6d638/charts/argocd-notifications/values.yaml#L158)
  EOT
}

variable "notifications_triggers" {
  type        = map(any)
  description = <<-EOT
  Notification Triggers to configure.

  See: https://argocd-notifications.readthedocs.io/en/stable/triggers/
  See: [Example value in argocd-notifications Helm Chart](https://github.com/argoproj/argo-helm/blob/a0a74fb43d147073e41aadc3d88660b312d6d638/charts/argocd-notifications/values.yaml#L352)
  EOT
}

variable "slack_notifications_enabled" {
  type        = bool
  default     = false
  description = "Whether or not to enable Slack notifications."
}

variable "slack_notifications_username" {
  type        = string
  description = "Custom username to use for Slack notifications."
}

variable "slack_notifications_icon" {
  type        = string
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
