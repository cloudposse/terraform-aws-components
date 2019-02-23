data "aws_caller_identity" "default" {}
data "aws_region" "default" {}

variable "chamber_user_enabled" {
  default     = "true"
  description = "Set to false to prevent the module from creating chamber user"
}

# Chamber user for CI/CD systems that cannot leverage IAM instance profiles
# https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-paramstore-access.html
module "chamber_user" {
  source      = "git::https://github.com/cloudposse/terraform-aws-iam-chamber-user.git?ref=tags/0.1.7"
  namespace   = "${var.namespace}"
  stage       = "${var.stage}"
  name        = "chamber"
  enabled     = "${var.chamber_user_enabled}"
  attributes  = ["codefresh"]
  kms_key_arn = "${module.chamber_kms_key.key_arn}"

  ssm_resources = [
    "${formatlist("arn:aws:ssm:%s:%s:parameter/%s/*", data.aws_region.default.name, data.aws_caller_identity.default.account_id, var.parameter_groups)}",
  ]
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
