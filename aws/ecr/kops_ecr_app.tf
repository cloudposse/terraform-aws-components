variable "kops_ecr_app_repository_name" {
  description = "App repository name"
  default     = "app"
}

variable "kops_ecr_app_enabled" {
  description = "Set to false to prevent the module kops_ecr_app from creating any resources"
  default     = "true"
}

module "kops_ecr_app" {
  source    = "git::https://github.com/cloudposse/terraform-aws-ecr.git?ref=use-only-participals-access-model"
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  name      = "${var.kops_ecr_app_repository_name}"

  enabled = "${var.kops_ecr_app_enabled}"
  
  principals_full_access = [
    "${module.kops_ecr_user.user_arn}"
  ]

  principals_readonly_access = [
    "${module.kops_metadata.masters_role_arn}",
    "${module.kops_metadata.nodes_role_arn}"
  ]

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
