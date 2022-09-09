variable "region" {
  description = "AWS Region."
  type        = string
}

variable "chart_description" {
  type        = string
  description = "Set release description attribute (visible in the history)."
  default     = null
}

variable "chart" {
  type        = string
  description = "Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended."
}

variable "chart_repository" {
  type        = string
  description = "Repository URL where to locate the requested chart."
}

variable "chart_version" {
  type        = string
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed."
  default     = null
}

variable "resources" {
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  description = "The cpu and memory of the deployment's limits and requests."
}

variable "create_namespace" {
  type        = bool
  description = "Create the namespace if it does not yet exist. Defaults to `false`."
  default     = null
}

variable "kubernetes_namespace" {
  type        = string
  description = "The namespace to install the release into."
}

variable "timeout" {
  type        = number
  description = "Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to `300` seconds"
  default     = null
}

variable "cleanup_on_fail" {
  type        = bool
  description = "Allow deletion of new resources created in this upgrade when upgrade fails."
  default     = true
}

variable "atomic" {
  type        = bool
  description = "If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used."
  default     = true
}

variable "wait" {
  type        = bool
  description = "Will wait until all resources are in a ready state before marking the release as successful. It will wait for as long as `timeout`. Defaults to `true`."
  default     = null
}

variable "chart_values" {
  type        = any
  description = "Additional values to yamlencode as `helm_release` values."
  default     = {}
}

variable "rbac_enabled" {
  type        = bool
  default     = true
  description = "Service Account for pods."
}

# argocd-notifications variables

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
