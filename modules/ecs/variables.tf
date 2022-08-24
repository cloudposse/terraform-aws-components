variable "region" {
  type        = string
  description = "AWS Region"
}

variable "alb_configuration" {
  type        = map(any)
  default     = {}
  description = "Map of multiple ALB configurations."
}

variable "alb_ingress_cidr_blocks_http" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDR blocks allowed to access environment over HTTP"
}

variable "alb_ingress_cidr_blocks_https" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDR blocks allowed to access environment over HTTPS"
}

variable "route53_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to create a route53 record for the ALB"
}

variable "acm_certificate_domain" {
  type        = string
  default     = null
  description = "Domain to get the ACM cert to use on the ALB."
}

variable "acm_certificate_domain_suffix" {
  type        = string
  default     = null
  description = "Domain suffix to use with dns delegated HZ to get the ACM cert to use on the ALB"
}

variable "route53_record_name" {
  type        = string
  default     = "*"
  description = "The route53 record name"
}

variable "internal_enabled" {
  type        = bool
  default     = false
  description = "Whether to create an internal load balancer for services in this cluster"
}

variable "maintenance_page_path" {
  type        = string
  default     = "templates/503_example.html"
  description = "The path from this directory to the text/html page to use as the maintenance page. Must be within 1024 characters"
}

variable "container_insights_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to enable container insights"
}

variable "dns_delegated_stage_name" {
  type        = string
  default     = null
  description = "Use this stage name to read from the remote state to get the dns_delegated zone ID"
}

variable "dns_delegated_environment_name" {
  type        = string
  default     = "gbl"
  description = "Use this environment name to read from the remote state to get the dns_delegated zone ID"
}

variable "dns_delegated_component_name" {
  type        = string
  default     = "dns-delegated"
  description = "Use this component name to read from the remote state to get the dns_delegated zone ID"
}
