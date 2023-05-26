variable "region" {
  type        = string
  description = "AWS Region"
}

variable "alb_names" {
  description = "list of ALB names which will be protected with AWS Shield Advanced"
  type        = list(string)
  default     = []
}

variable "cloudfront_distribution_ids" {
  description = "list of CloudFront Distribution IDs which will be protected with AWS Shield Advanced"
  type        = list(string)
  default     = []
}

variable "eips" {
  description = "List of Elastic IPs which will be protected with AWS Shield Advanced"
  type        = list(string)
  default     = []
}

variable "route53_zone_names" {
  description = "List of Route53 Hosted Zone names which will be protected with AWS Shield Advanced"
  type        = list(string)
  default     = []
}
