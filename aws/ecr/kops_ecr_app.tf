variable "kops_ecr_app_repository_name" {
  description = "App repository name"
}

module "kops_ecr_app" {
  source    = "git::https://github.com/cloudposse/terraform-aws-ecr.git?ref=tags/0.3.0"
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  name      = "${var.kops_ecr_app_repository_name}"

  principals_full_access    = ["${local.principals_full_access}"]
  principals_readonly_access = ["${local.principals_readonly_access}"]

  tags = "${module.label.tags}"
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
