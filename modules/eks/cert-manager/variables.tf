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
  default     = "cert-manager"
}

variable "cert_manager_repository" {
  type        = string
  description = "Repository URL where to locate the requested chart."
  default     = "https://charts.jetstack.io"
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
  default = {
    limits = {
      cpu    = "200m"
      memory = "256Mi"
    }
    requests = {
      cpu    = "100m"
      memory = "128Mi"
    }
  }
}

variable "cart_manager_rbac_enabled" {
  type        = bool
  description = "Service Account for pods."
  default     = true
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
  default     = "./cert-manager-issuer/"
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
  description = "Create the namespace if it does not yet exist. Defaults to `true`."
  default     = true
}

variable "kubernetes_namespace" {
  type        = string
  description = "The namespace to install the release into."
  default     = "cert-manager"
}

variable "timeout" {
  type        = number
  description = "Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to `300` seconds"
  default     = null
}

variable "cleanup_on_fail" {
  type        = bool
  description = "If `true`, resources created in this deploy will be deleted when deploy fails. Highly recommended to prevent cert-manager from getting into a wedged state."
  default     = true
}

variable "atomic" {
  type        = bool
  description = "If `true`, if any part of the installation process fails, all parts are treated as failed. Highly recommended to prevent cert-manager from getting into a wedged state. The wait flag will be set automatically if atomic is used."
  default     = true
}

variable "wait" {
  type        = bool
  description = "Set `true` to wait until all resources are in a ready state before marking the release as successful. Ignored if provisioning Issuers. It will wait for as long as `timeout`. Defaults to `true`."
  default     = true
}

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
}
