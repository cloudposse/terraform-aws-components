variable "region" {
  type        = string
  description = "AWS Region"
}

variable "prometheus_component_name" {
  type        = string
  description = "The name of the Amazon Managed Prometheus component to be added as a Grafana data source"
  default     = "managed-prometheus/workspace"
}

variable "prometheus_stage_name" {
  type        = string
  description = "The stage where the Amazon Managed Prometheus component is deployed"
  default     = ""
}

variable "prometheus_environment_name" {
  type        = string
  description = "The environment where the Amazon Managed Prometheus component is deployed"
  default     = ""
}

variable "prometheus_tenant_name" {
  type        = string
  description = "The tenant where the Amazon Managed Prometheus component is deployed"
  default     = ""
}
