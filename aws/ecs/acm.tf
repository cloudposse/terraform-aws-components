variable "domain_name" {
  description = "A domain name for which the certificate should be issued"
}

variable "subject_alternative_names" {
  description = "A list of domains that should be SANs in the issued certificate"
  default     = []
}

module "acm_request_certificate" {
  source                            = "git::https://github.com/cloudposse/terraform-aws-acm-request-certificate.git?ref=tags/0.2.2"
  domain_name                       = "${var.domain_name}"
  process_domain_validation_options = "true"
  ttl                               = "300"
  subject_alternative_names         = "${var.subject_alternative_names}"
  tags                              = "${var.tags}"
}
