output "administrator_role_arn" {
  value = "${module.admin.arn}"
}

output "executor_role_name" {
  value = "${module.executor_role_name.id}"
}
