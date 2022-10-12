variable "region" {
  type        = string
  description = "AWS Region"
}

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/cluster"
}

variable "alb_controller_ingress_group_component_name" {
  type        = string
  description = "The name of the alb-controller-ingress-group component"
  default     = "eks/alb-controller-ingress-group"
}

variable "enable_alb_controller_ingress_group" {
  type        = bool
  description = "Uses alb-controller-ingress-group component for alb ingress group"
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
