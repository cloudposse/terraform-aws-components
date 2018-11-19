variable "kops_ecr_app_repository_name" {
  description = "App repository name"
}

module "kops_ecr_app" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-ecr.git?ref=use-roles-instead-of-users"
  namespace    = "${var.namespace}"
  stage        = "${var.stage}"
  name         = "${var.kops_ecr_app_repository_name}"
  cluster_name = "${var.region}.${var.zone_name}"

  roles = [
    "${module.kops_ecr_user.role_name}",
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
