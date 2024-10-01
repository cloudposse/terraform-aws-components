terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

variable "aws_assume_role_arn" {}

provider "aws" {
  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

module "certificate" {
  source                            = "git::https://github.com/cloudposse/terraform-aws-acm-request-certificate.git?ref=tags/0.1.1"
  domain_name                       = var.domain_name
  process_domain_validation_options = "true"
  ttl                               = "300"
  subject_alternative_names         = ["*.${var.domain_name}"]
}

resource "aws_ssm_parameter" "certificate_arn_parameter" {
  name        = format(var.chamber_parameter_name, var.chamber_service, var.certificate_arn_parameter_name)
  value       = module.certificate.arn
  description = "Teleport ACM-issued TLS Certificate AWS ARN"
  type        = "String"
  overwrite   = "true"
}
