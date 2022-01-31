variable "region" {
  type        = string
  description = "AWS Region"
}

variable "secrets_store_type" {
  type        = string
  description = "Secret store type for Datadog API and app keys. Valid values: `SSM`, `ASM`"
  default     = "SSM"
}

variable "datadog_secrets_source_store_account" {
  type        = string
  description = "Account (stage) holding Secret Store for Datadog API and app keys."
  default     = "auto"
}

variable "datadog_api_secret_key" {
  type        = string
  description = "The key of the Datadog API secret"
  default     = "datadog/datadog_api_key"
}

variable "datadog_app_secret_key" {
  type        = string
  description = "The key of the Datadog Application secret"
  default     = "datadog/datadog_app_key"
}

variable "datadog_tags" {
  type        = list(string)
  description = "List of static tags to attach to every metric, event and service check collected by the agent"
  default     = []
}
variable "description" {
  type        = string
  description = "Release description attribute (visible in the history)"
  default     = null
}

variable "chart" {
  type        = string
  description = "Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended"
}

variable "repository" {
  type        = string
  description = "Repository URL where to locate the requested chart"
  default     = null
}

variable "chart_version" {
  type        = string
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed"
  default     = null
}

variable "kubernetes_namespace" {
  type        = string
  description = "Kubernetes namespace to install the release into"
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
