variable "region" {
  type        = string
  description = "AWS Region"
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

variable "additional_annotations" {
  type        = map(any)
  description = "Additional annotations to add to the Kubernetes ingress"
  default     = {}
}

variable "default_annotations" {
  type        = map(any)
  description = "Default annotations to add to the Kubernetes ingress"

  default = {
    "alb.ingress.kubernetes.io/scheme"       = "internet-facing"
    "alb.ingress.kubernetes.io/target-type"  = "ip"
    "kubernetes.io/ingress.class"            = "alb"
    "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
  }
}

variable "dns_delegated_environment_name" {
  type        = string
  description = "Global environment name"
  default     = "gbl"
}

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
}

variable "global_accelerator_enabled" {
  type        = bool
  description = "Whether or not Global Accelerator Endpoint Group should be provisioned for the load balancer"
  default     = false
}

variable "waf_enabled" {
  type        = bool
  description = "Whether or not WAF ACL annotation should be provisioned for the load balancer"
  default     = false
}

variable "alb_access_logs_enabled" {
  type        = bool
  description = "Whether or not to enable access logs for the ALB"
  default     = false
}

variable "alb_access_logs_s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to store the access logs in"
  default     = null
}

variable "alb_access_logs_s3_bucket_prefix" {
  type        = string
  description = "The prefix to use when storing the access logs"
  default     = "echo-server"
}

variable "kubernetes_service_enabled" {
  type        = bool
  description = "Whether or not to enable a default kubernetes service"
  default     = false
}

variable "kubernetes_service_port" {
  type        = number
  description = "The kubernetes default service's port if enabled"
  default     = 8080
}

variable "kubernetes_service_path" {
  type        = string
  description = "The kubernetes default service's path if enabled"
  default     = "/*"
}

variable "fixed_response_template" {
  type        = string
  description = "Fixed response template to service as a default backend"
  default     = "resources/default-backend.html.tpl"

  validation {
    condition     = length(file(var.fixed_response_template)) < 1024
    error_message = "The length of the template must be less than 1024 characters."
  }
}

variable "fixed_response_config" {
  type        = map(any)
  description = "Configuration to overwrite the defaults such as `contentType`, `statusCode`, and `messageBody`"
  default     = {}
}

variable "fixed_response_vars" {
  type        = map(any)
  description = "The templatefile vars to use for the fixed response template"
  default = {
    email = "hello@cloudposse.com"
  }
}
