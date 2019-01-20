variable "domain_name" {
  description = "A domain name for which the certificate should be issued"
  default     = ""
}

variable "subject_alternative_names" {
  description = "A list of domains that should be SANs in the issued certificate"
  default     = []
}

locals {
  domain_name               = "${length(var.domain_name) > 0 ? var.domain_name : module.dns.zone_name}"
  subject_alternative_names = "${length(var.subject_alternative_names) > 0 ? var.subject_alternative_names : formatlist("*.%s", list(module.dns.zone_name))}"
}

module "acm_request_certificate" {
  source                    = "git::https://github.com/cloudposse/terraform-aws-acm-request-certificate.git?ref=tags/0.1.1"
  domain_name               = "${local.domain_name}"
  ttl                       = "300"
  subject_alternative_names = "${local.subject_alternative_names}"
  tags                      = "${var.tags}"
}
