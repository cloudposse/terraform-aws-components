terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

variable "aws_assume_role_arn" {}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

variable "domain_name" {
  description = "Domain name (E.g. staging.cloudposse.org)"
}

module "certificate" {
  source                           = "git::https://github.com/cloudposse/terraform-aws-acm-request-certificate.git?ref=tags/0.1.1"
  domain_name                      = "${var.domain_name}"
  proces_domain_validation_options = "true"
  ttl                              = "300"
  subject_alternative_names        = ["*.${var.domain_name}"]
}

output "certificate_domain_name" {
  value = "${var.domain_name}"
}

output "certificate_id" {
  value = "${module.certificate.id}"
}

output "certificate_arn" {
  value = "${module.certificate.arn}"
}

output "certificate_domain_validation_options" {
  value = "${module.certificate.domain_validation_options}"
}
