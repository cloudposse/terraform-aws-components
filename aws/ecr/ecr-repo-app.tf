module "kops_ecr_app" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-ecr.git?ref=tags/0.1.0"
  namespace    = "${var.namespace}"
  stage        = "${var.stage}"
  name         = "${element(repositories_names,0)}"
  cluster_name = "${var.region}.${var.zone_name}"

  users = [
    "${module.kops_ecr_user.user_name}",
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
  value       = "${module.kops_ecr_app.repository_url}"
  description = "Registry app URL"
}

output "kops_ecr_app_repository_name" {
  value       = "${module.kops_ecr_app.name}"
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
