variable "kops_ecr_app_repository_name" {
  description = "App repository name"
}

module "kops_ecr_app" {
  source    = "git::https://github.com/cloudposse/terraform-aws-ecr.git?ref=fix-iam-limit-solution-2"
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  name      = "${var.kops_ecr_app_repository_name}"

  principal = [
    "${module.kops_ecr_user.user_arn}",
  ]

  principal_readonly = [
    "${module.kops_metadata.masters_role_arn}",
    "${module.kops_metadata.nodes_role_arn}",
  ]

  tags = {
    Cluster = "${var.region}.${var.zone_name}"
  }
}

output "kops_ecr_app_registry_id" {
  value       = "${module.kops_ecr_app.registry_id}"
  description = "Registry app ID"
}

output "kops_ecr_app_registry_url" {
  value       = "${module.kops_ecr_app.registry_url}"
  description = "Registry app URL"
}

output "kops_ecr_app_repository_name" {
  value       = "${module.kops_ecr_app.repository_name}"
  description = "Registry app name"
}

output "kops_ecr_app_role_name" {
  value       = "${module.kops_ecr_app.role_name}"
  description = "Assume Role name to get access app registry"
}

output "kops_ecr_app_role_arn" {
  value       = "${module.kops_ecr_app.role_arn}"
  description = "Assume Role ARN to get access app registry"
}
