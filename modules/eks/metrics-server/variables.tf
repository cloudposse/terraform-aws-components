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
  default     = "metrics-server"
}

variable "chart_repository" {
  type        = string
  description = "Repository URL where to locate the requested chart."
  default     = "https://charts.bitnami.com/bitnami"
}

variable "chart_version" {
  type        = string
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed."
  default     = "6.2.6"
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
  default = {
    limits = {
      cpu    = "100m"
      memory = "300Mi"
    }
    requests = {
      cpu    = "20m"
      memory = "60Mi"
    }
  }
}

variable "create_namespace" {
  type        = bool
  description = "Create the namespace if it does not yet exist. Defaults to `false`."
  default     = true
}

variable "kubernetes_namespace" {
  type        = string
  description = "The namespace to install the release into."
  default     = "metrics-server"
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

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
}
