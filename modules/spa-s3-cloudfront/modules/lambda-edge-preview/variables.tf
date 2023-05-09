variable "cloudfront_distribution_domain_name" {
  type        = string
  description = "Cloudfront Distribution Domain Name."
}

variable "cloudfront_distribution_hosted_zone_id" {
  type        = string
  description = "The CloudFront Distribution Hosted Zone ID."
}

variable "parent_zone_name" {
  type        = string
  description = "The name of the Route53 Hosted Zone where aliases for the CloudFront distribution are created."
}

variable "site_fqdn" {
  type        = string
  description = "The fully qualified alias for the CloudFront Distribution."
}
