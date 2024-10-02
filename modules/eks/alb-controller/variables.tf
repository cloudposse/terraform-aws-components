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

####### Configure default Ingress Class #######

variable "default_ingress_enabled" {
  type        = bool
  description = "Set `true` to deploy a default IngressClass. There should only be one default per cluster."
  default     = true
}

variable "default_ingress_class_name" {
  type        = string
  description = "Class name for default ingress"
  default     = "default"
}

variable "default_ingress_group" {
  type        = string
  description = "Group name for default ingress"
  default     = "common"
}

variable "default_ingress_scheme" {
  type        = string
  description = "Scheme for default ingress, one of `internet-facing` or `internal`."
  default     = "internet-facing"

  validation {
    condition     = contains(["internet-facing", "internal"], var.default_ingress_scheme)
    error_message = "The default ingress scheme must be one of `internet-facing` or `internal`."
  }
}

variable "default_ingress_ip_address_type" {
  type        = string
  description = "IP address type for default ingress, one of `ipv4` or `dualstack`."
  default     = "ipv4"

  validation {
    condition     = contains(["ipv4", "dualstack"], var.default_ingress_ip_address_type)
    error_message = "The default ingress IP address type must be one of `ipv4` or `dualstack`."
  }
}

variable "default_ingress_load_balancer_attributes" {
  type        = list(object({ key = string, value = string }))
  description = <<-EOT
    A list of load balancer attributes to apply to the default ingress load balancer.
    See [Load Balancer Attributes](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html#load-balancer-attributes).
    EOT
  default     = []
}

variable "default_ingress_additional_tags" {
  type        = map(string)
  description = "Additional tags to apply to the ingress load balancer."
  default     = {}
}
