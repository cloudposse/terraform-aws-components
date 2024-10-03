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
  default = {
    limits = {
      cpu    = "200m"
      memory = "256Mi"
    },
    requests = {
      cpu    = "100m"
      memory = "128Mi"
    }
  }
}

variable "metrics_enabled" {
  type        = bool
  description = "Whether or not to enable metrics in the helm chart."
  default     = false
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
  description = "Addition map values to yamlencode as `helm_release` values."
  default     = {}
}

variable "txt_prefix" {
  type        = string
  default     = "external-dns"
  description = "Prefix to create a TXT record with a name following the pattern prefix.`<CNAME record>`."
}

variable "crd_enabled" {
  type        = bool
  default     = false
  description = "Install and use the integrated DNSEndpoint CRD."
}

variable "istio_enabled" {
  type        = bool
  default     = false
  description = "Add istio gateways to monitored sources."
}

variable "rbac_enabled" {
  type        = bool
  default     = true
  description = "Service Account for pods."
}

variable "dns_gbl_delegated_environment_name" {
  type        = string
  description = "The name of the environment where global `dns_delegated` is provisioned"
  default     = "gbl"
}

variable "dns_gbl_primary_environment_name" {
  type        = string
  description = "The name of the environment where global `dns_primary` is provisioned"
  default     = "gbl"
}


variable "dns_components" {
  type = list(object({
    component   = string,
    environment = optional(string)
  }))
  description = "A list of additional DNS components to search for ZoneIDs"
  default     = []
}

variable "publish_internal_services" {
  type        = bool
  description = "Allow external-dns to publish DNS records for ClusterIP services"
  default     = true
}

variable "policy" {
  type        = string
  description = "Modify how DNS records are synchronized between sources and providers (options: sync, upsert-only)"
  default     = "sync"
}

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
}
