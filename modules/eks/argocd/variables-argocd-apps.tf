variable "argocd_apps_chart_description" {
  type        = string
  description = "Set release description attribute (visible in the history)."
  default     = null
}

variable "argocd_apps_chart" {
  type        = string
  description = "Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended."
}

variable "argocd_apps_chart_repository" {
  type        = string
  description = "Repository URL where to locate the requested chart."
}

variable "argocd_apps_chart_version" {
  type        = string
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed."
  default     = null
}
