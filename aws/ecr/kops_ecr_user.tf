module "kops_ecr_user" {
  source    = "git::https://github.com/cloudposse/terraform-aws-iam-system-user.git?ref=tags/0.3.0"
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  name      = "cicd"

  tags = {
    Cluster = "${var.region}.${var.zone_name}"
  }
}

output "kops_ecr_user_name" {
  value       = "${module.kops_ecr_user.user_name}"
  description = "Normalized IAM user name"
}

output "kops_ecr_user_arn" {
  value       = "${module.kops_ecr_user.user_arn}"
  description = "The ARN assigned by AWS for the user"
}

output "kops_ecr_user_unique_id" {
  value       = "${module.kops_ecr_user.user_unique_id}"
  description = "The user unique ID assigned by AWS"
}

output "kops_ecr_user_access_key_id" {
  value       = "${module.kops_ecr_user.access_key_id}"
  description = "The access key ID"
}

output "kops_ecr_user_secret_access_key" {
  value       = "${module.kops_ecr_user.secret_access_key}"
  description = "The secret access key. This will be written to the state file in plain-text"
}
