terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

variable "aws_assume_role_arn" {
  type = "string"
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

module "datadog_ids" {
  source         = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  parameter_read = ["/datadog/datadog_external_id"]
}

module "datadog_aws_integration" {
  source              = "git::https://github.com/cloudposse/terraform-datadog-aws-integration.git?ref=tags/0.2.0"
  namespace           = "${var.namespace}"
  stage               = "${var.stage}"
  name                = "datadog"
  datadog_external_id = "${lookup(module.datadog_ids.map, "/datadog/datadog_external_id")}"
  integrations        = "${var.integrations}"
}
