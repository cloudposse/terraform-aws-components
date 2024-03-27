variable "region" {
  type        = string
  description = "AWS Region"
}

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
}

variable "chart_values" {
  type        = any
  description = "Addition map values to yamlencode as `helm_release` values."
  default     = {}
}

variable "deployment_name" {
  type        = string
  description = "Name of the tailscale deployment, defaults to `tailscale` if this is null"
  default     = null
}

variable "image_repo" {
  type        = string
  description = "Image repository for the deployment"
  default     = "ghcr.io/tailscale/tailscale"
}

variable "image_tag" {
  type        = string
  description = "Image Tag for the deployment."
  default     = "latest"
}

variable "create_namespace" {
  type        = bool
  description = "Create the namespace if it does not yet exist. Defaults to `false`."
  default     = false
}

variable "kubernetes_namespace" {
  type        = string
  description = "The namespace to install the release into."
}

variable "kube_secret" {
  type        = string
  description = "Kube Secret Name for tailscale"
  default     = "tailscale"
}

variable "routes" {
  type        = list(string)
  description = "List of CIDR Ranges or IPs to allow Tailscale to connect to"
  default     = []
}

variable "env" {
  type        = map(string)
  description = "Map of ENV vars in the format `key=value`. These ENV vars will be set in the `utils` provider before executing the data source"
  default     = null
}
