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

module "identity" {
  source = "git::git@github.com:cloudposse/terraform-aws-account-metadata.git?ref=init"
}

module "chamber_kms_key" {
  source      = "git::https://github.com/cloudposse/terraform-aws-kms-key.git?ref=tags/0.1.0"
  namespace   = "${module.identity.namespace}"
  stage       = "${module.identity.stage}"
  name        = "chamber"
  description = "KMS key for chamber"
}

# Chamber user for CI/CD systems that cannot leverage IAM instance profiles
# https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-paramstore-access.html
module "chamber_user" {
  source        = "git::https://github.com/cloudposse/terraform-aws-iam-chamber-user.git?ref=tags/0.1.4"
  namespace     = "${module.identity.namespace}"
  stage         = "${module.identity.stage}"
  name          = "chamber"
  attributes    = ["codefresh"]
  kms_key_arn   = "${module.chamber_kms_key.key_arn}"
  ssm_resources = ["${format("arn:aws:ssm:%s:%s:parameter/kops/*", module.identity.aws_region, module.identity.account_id)}"]
}

output "chamber_kms_key_arn" {
  value       = "${module.chamber_kms_key.key_arn}"
  description = "KMS key ARN"
}

output "chamber_kms_key_id" {
  value       = "${module.chamber_kms_key.key_id}"
  description = "KMS key ID"
}

output "chamber_kms_key_alias_arn" {
  value       = "${module.chamber_kms_key.alias_arn}"
  description = "KMS key alias ARN"
}

output "chamber_kms_key_alias_name" {
  value       = "${module.chamber_kms_key.alias_name}"
  description = "KMS key alias name"
}

output "chamber_user_name" {
  value       = "${module.chamber_user.user_name}"
  description = "Normalized IAM user name"
}

output "chamber_user_arn" {
  value       = "${module.chamber_user.user_arn}"
  description = "The ARN assigned by AWS for the user"
}

output "chamber_user_unique_id" {
  value       = "${module.chamber_user.user_unique_id}"
  description = "The user unique ID assigned by AWS"
}

output "chamber_access_key_id" {
  value       = "${module.chamber_user.access_key_id}"
  description = "The access key ID"
}

output "chamber_secret_access_key" {
  value       = "${module.chamber_user.secret_access_key}"
  description = "The secret access key. This will be written to the state file in plain-text"
}
