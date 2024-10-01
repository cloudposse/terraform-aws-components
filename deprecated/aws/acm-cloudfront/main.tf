terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

variable "aws_assume_role_arn" {
  type = string
}

provider "aws" {
  #  CloudFront certs must be created in the `aws-east-1` region, even if your origin is in a different one
  # This is a CloudFront limitation
  # https://christian.legnitto.com/blog/2017/10/11/terraform-and-cloudfront-gotchas/
  # https://medium.com/modern-stack/5-minute-static-ssl-website-in-aws-with-terraform-76819a12d412
  # https://medium.com/runatlantis/hosting-our-static-site-over-ssl-with-s3-acm-cloudfront-and-terraform-513b799aec0f
  region = "us-east-1"

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

variable "domain_name" {
  description = "Domain name (E.g. staging.cloudposse.co)"
}

module "certificate" {
  source                            = "git::https://github.com/cloudposse/terraform-aws-acm-request-certificate.git?ref=tags/0.1.1"
  domain_name                       = var.domain_name
  process_domain_validation_options = "true"
  ttl                               = "300"
  subject_alternative_names         = ["*.${var.domain_name}"]
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
