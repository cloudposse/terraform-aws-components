variable "subject_alternative_names" {
  type        = list(string)
  description = "A list of domains that should be SANs in the issued certificate"
  default     = []
}

variable "domain_name" {
  type        = string
  description = "Domain name (E.g. staging.cloudposse.co)"
  default     = ""
}

locals {
  domain_name = var.domain_name != "" ? var.domain_name : module.dns.zone_name

  subject_alternative_names = distinct(
    concat(
      var.subject_alternative_names,
      formatlist("*.%s", [local.domain_name])
    )
  )
}

module "acm_request_certificate" {
  source                    = "git::https://github.com/cloudposse/terraform-aws-acm-request-certificate.git?ref=tags/0.4.0"
  domain_name               = local.domain_name
  ttl                       = 300
  subject_alternative_names = local.subject_alternative_names
  tags                      = var.tags
}
