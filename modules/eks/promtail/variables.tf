variable "region" {
  type        = string
  description = "AWS Region"
}

variable "chart_description" {
  type        = string
  description = "Set release description attribute (visible in the history)."
  default     = "Promtail is an agent which ships the contents of local logs to a Loki instance"
}

variable "chart" {
  type        = string
  description = "Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended."
  default     = "promtail"
}

variable "chart_repository" {
  type        = string
  description = "Repository URL where to locate the requested chart."
  default     = "https://grafana.github.io/helm-charts"
}

variable "chart_version" {
  type        = string
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed."
  default     = null
}

variable "kubernetes_namespace" {
  type        = string
  description = "Kubernetes namespace to install the release into"
  default     = "monitoring"
}

variable "create_namespace" {
  type        = bool
  description = "Create the Kubernetes namespace if it does not yet exist"
  default     = true
}

variable "verify" {
  type        = bool
  description = "Verify the package before installing it. Helm uses a provenance file to verify the integrity of the chart; this must be hosted alongside the chart"
  default     = false
}

variable "wait" {
  type        = bool
  description = "Will wait until all resources are in a ready state before marking the release as successful. It will wait for as long as `timeout`. Defaults to `true`."
  default     = true
}

variable "atomic" {
  type        = bool
  description = "If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used."
  default     = true
}

variable "cleanup_on_fail" {
  type        = bool
  description = "Allow deletion of new resources created in this upgrade when upgrade fails."
  default     = true
}

variable "timeout" {
  type        = number
  description = "Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to `300` seconds"
  default     = 300
}

variable "chart_values" {
  type        = any
  description = "Additional values to yamlencode as `helm_release` values."
  default     = {}
}

variable "push_api" {
  type = object({
    enabled       = optional(bool, false)
    scrape_config = optional(string, "")
  })
  description = <<-EOT
  Describes and configures Promtail to expose a Loki push API server with an Ingress configuration.

  - enabled: Set this to `true` to enable this feature
  - scrape_config: Optional. This component includes a basic configuration by default, or override the default configuration here.

  EOT
  default     = {}
}

variable "scrape_configs" {
  type        = list(string)
  description = "A list of local path paths starting with this component's base path for Promtail Scrape Configs"
  default = [
    "scrape_config/default_kubernetes_pods.yaml"
  ]
}
