variable "region" {
  type        = string
  description = "AWS Region"
}

variable "basic_auth_enabled" {
  type        = bool
  description = "If `true`, enabled Basic Auth for the Ingress service. A user and password will be created and stored in AWS SSM."
  default     = true
}

variable "ssm_path_template" {
  type        = string
  description = "A string template to be used to create paths in AWS SSM to store basic auth credentials for this service"
  default     = "/%s/basic-auth/%s"
}

variable "chart_description" {
  type        = string
  description = "Set release description attribute (visible in the history)."
  default     = "Loki is a horizontally-scalable, highly-available, multi-tenant log aggregation system inspired by Prometheus."
}

variable "chart" {
  type        = string
  description = "Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended."
  default     = "loki"
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

variable "default_schema_config" {
  type = list(object({
    from         = string
    object_store = string
    schema       = string
    index = object({
      prefix = string
      period = string
    })
  }))
  description = "A list of default `configs` for the `schemaConfig` for the Loki chart. For new installations, the default schema config doesn't change. See https://grafana.com/docs/loki/latest/operations/storage/schema/#new-loki-installs"
  default = [
    {
      from         = "2024-04-01" # for a new install, this must be a date in the past, use a recent date. Format is YYYY-MM-DD.
      object_store = "s3"
      store        = "tsdb"
      schema       = "v13"
      index = {
        prefix = "index_"
        period = "24h"
      }
    }
  ]
}

variable "additional_schema_config" {
  type = list(object({
    from         = string
    object_store = string
    schema       = string
    index = object({
      prefix = string
      period = string
    })
  }))
  description = "A list of additional `configs` for the `schemaConfig` for the Loki chart. This list will be merged with the default schemaConfig.config defined by `var.default_schema_config`"
  default     = []
}
