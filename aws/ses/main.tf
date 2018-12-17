terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }

  region = "${var.ses_region}"
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "ses_region" {
  type        = "string"
  description = "AWS Region the SES should reside in"
  default     = "us-west-2"
}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "ses_name" {
  type        = "string"
  description = "Application or solution name (e.g. `app`)"
  default     = "ses"
}

variable "parent_domain_name" {
  type        = "string"
  description = "Root domain name"
}

module "ses" {
  source = "git::https://github.com/cloudposse/terraform-aws-ses-lambda-forwarder.git?ref=tags/0.2.0"

  namespace = "${var.namespace}"
  name      = "${var.ses_name}"
  stage     = "${var.stage}"

  region = "${var.ses_region}"

  relay_email = "${var.relay_email}"
  domain      = "${var.parent_domain_name}"

  forward_emails = "${var.forward_emails}"
}
