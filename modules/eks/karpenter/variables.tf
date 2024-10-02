variable "region" {
  type        = string
  description = "AWS Region"
}

variable "chart_description" {
  type        = string
  description = "Set release description attribute (visible in the history)"
  default     = null
}

variable "chart" {
  type        = string
  description = "Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended"
}

variable "chart_repository" {
  type        = string
  description = "Repository URL where to locate the requested chart"
}

variable "chart_version" {
  type        = string
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed"
  default     = null
}

variable "crd_chart_enabled" {
  type        = bool
  description = "`karpenter-crd` can be installed as an independent helm chart to manage the lifecycle of Karpenter CRDs. Set to `true` to install this CRD helm chart before the primary karpenter chart."
  default     = false
}

variable "crd_chart" {
  type        = string
  description = "The name of the Karpenter CRD chart to be installed, if `var.crd_chart_enabled` is set to `true`."
  default     = "karpenter-crd"
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
  description = "The CPU and memory of the deployment's limits and requests"
}

variable "timeout" {
  type        = number
  description = "Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to `300` seconds"
  default     = null
}

variable "cleanup_on_fail" {
  type        = bool
  description = "Allow deletion of new resources created in this upgrade when upgrade fails"
  default     = true
}

variable "atomic" {
  type        = bool
  description = "If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used"
  default     = true
}

variable "wait" {
  type        = bool
  description = "Will wait until all resources are in a ready state before marking the release as successful. It will wait for as long as `timeout`. Defaults to `true`"
  default     = null
}

variable "chart_values" {
  type        = any
  description = "Additional values to yamlencode as `helm_release` values"
  default     = {}
}

variable "rbac_enabled" {
  type        = bool
  description = "Enable/disable RBAC"
  default     = true
}

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
}

variable "interruption_handler_enabled" {
  type        = bool
  default     = true
  description = <<EOD
  If `true`, deploy a SQS queue and Event Bridge rules to enable interruption handling by Karpenter.
  https://karpenter.sh/docs/concepts/disruption/#interruption
  EOD
}

variable "interruption_queue_message_retention" {
  type        = number
  default     = 300
  description = "The message retention in seconds for the interruption handler SQS queue."
}

variable "replicas" {
  type        = number
  description = "The number of Karpenter controller replicas to run"
  default     = 2
}

variable "settings" {
  type = object({
    batch_idle_duration = optional(string, "1s")
    batch_max_duration  = optional(string, "10s")
  })
  description = <<-EOT
  A subset of the settings for the Karpenter controller.
  Some settings are implicitly set by this component, such as `clusterName` and
  `interruptionQueue`. All settings can be overridden by providing a `settings`
  section in the `chart_values` variable. The settings provided here are the ones
  mostly likely to be set to other than default values, and are provided here for convenience.
  EOT
  default     = {}
  nullable    = false
}

variable "logging" {
  type = object({
    enabled = optional(bool, true)
    level = optional(object({
      controller = optional(string, "info")
      global     = optional(string, "info")
      webhook    = optional(string, "error")
    }), {})
  })
  description = "A subset of the logging settings for the Karpenter controller"
  default     = {}
  nullable    = false
}
