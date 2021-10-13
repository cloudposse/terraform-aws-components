variable "kops_acm_enabled" {
  description = "Set to false to prevent the acm module from creating any resources"
  default     = "false"
}

variable "kops_acm_san_domains" {
  type        = "list"
  default     = []
  description = "A list of domains (except *.{cluster_name}) that should be SANs in the issued certificate"
}

resource "aws_acm_certificate" "default" {
  count                     = "${var.kops_acm_enabled ? 1 : 0}"
  domain_name               = "*.${var.region}.${var.zone_name}"
  validation_method         = "DNS"
  subject_alternative_names = ["${var.kops_acm_san_domains}"]
  tags                      = "${var.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

output "kops_acm_arn" {
  value       = "${join("", aws_acm_certificate.default.*.arn)}"
  description = "The ARN of the certificate"
}

output "kops_acm_domain_validation_options" {
  value       = "${flatten(aws_acm_certificate.default.*.domain_validation_options)}"
  description = "CNAME records that need to be added to the DNS zone to complete certificate validation"
}
