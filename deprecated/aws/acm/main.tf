terraform {
  backend "s3" {}
}


provider "aws" {
  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}



module "certificate" {
  source                            = "git::https://github.com/cloudposse/terraform-aws-acm-request-certificate.git?ref=tags/0.4.0"
  domain_name                       = var.domain_name
  process_domain_validation_options = true
  ttl                               = 300
  subject_alternative_names         = ["*.${var.domain_name}"]
}

resource "aws_ssm_parameter" "certificate_arn_parameter" {
  name        = format(var.chamber_parameter_name_format, var.chamber_service, var.certificate_arn_parameter_name)
  value       = module.certificate.arn
  description = "ACM-issued TLS Certificate ARN"
  type        = "String"
  overwrite   = true
}

output "certificate_domain_name" {
  value = var.domain_name
}

output "certificate_id" {
  value = module.certificate.id
}

output "certificate_arn" {
  value = module.certificate.arn
}

output "certificate_domain_validation_options" {
  value = module.certificate.domain_validation_options
}
