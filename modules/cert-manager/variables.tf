variable "region" {
  type        = string
  description = "AWS Region"
}

## shared between cert_manager and cert_manager_issuer

variable "letsencrypt_enabled" {
  type        = bool
  description = "Whether or not to use letsencrypt issuer and manager. If this is enabled, it will also provision an IAM role."
  default     = false
}

## cert_manager

variable "cert_manager_description" {
  type        = string
  description = "Set release description attribute (visible in the history)."
  default     = null
}

variable "cert_manager_chart" {
  type        = string
  description = "Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended."
}

variable "cert_manager_repository" {
  type        = string
  description = "Repository URL where to locate the requested chart."
  default     = null
}

variable "cert_manager_chart_version" {
  type        = string
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed."
  default     = null
}

variable "cert_manager_resources" {
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
  description = "The cpu and memory of the cert manager's limits and requests."
}

variable "cart_manager_rbac_enabled" {
  type        = bool
  default     = true
  description = "Service Account for pods."
}

variable "cert_manager_metrics_enabled" {
  type        = bool
  description = "Whether or not to enable metrics for cert-manager."
  default     = false
}

variable "cert_manager_values" {
  type        = any
  description = "Additional values to yamlencode as `helm_release` values for cert-manager."
  default     = {}
}

## cert_manager_issuer

variable "cert_manager_issuer_description" {
  type        = string
  description = "Set release description attribute (visible in the history)."
  default     = null
}

variable "cert_manager_issuer_chart" {
  type        = string
  description = "Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended."
}

variable "cert_manager_issuer_repository" {
  type        = string
  description = "Repository URL where to locate the requested chart."
  default     = null
}

variable "cert_manager_issuer_chart_version" {
  type        = string
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed."
  default     = null
}

variable "cert_manager_issuer_support_email_template" {
  type        = string
  description = "The support email template format."
}

variable "cert_manager_issuer_selfsigned_enabled" {
  type        = bool
  description = "Whether or not to use selfsigned issuer."
  default     = true
}

variable "cert_manager_issuer_values" {
  type        = any
  description = "Additional values to yamlencode as `helm_release` values for cert-manager-issuer."
  default     = {}
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
