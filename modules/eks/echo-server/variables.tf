variable "region" {
  type        = string
  description = "AWS Region"
}

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
}

variable "alb_controller_group_name" {
  type        = string
  description = "The name of the ALB controller Ingress group to use"
  default     = ""
}

variable "alb_controller_load_balancer_name" {
  type        = string
  description = "The name to assign to the load balancer created by the ALB controller"
  default     = ""
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

variable "ipv6_enabled" {
  type        = bool
  description = "Set true to enable IPv6 addressing of the ingress"
  default     = false
}
