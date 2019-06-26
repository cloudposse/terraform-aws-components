output "administrator_role_arn" {
  value = "${module.admin.arn}"
}

output "execution_role_name" {
  value = "${module.execution_role_name.id}"
}
