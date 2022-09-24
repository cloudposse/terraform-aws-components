output "role_name_role_arn_map" {
  description = "Map of role names to role ARNs"
  value       = local.role_name_role_arn_map
}

resource "local_file" "account_info" {
  content = templatefile("${path.module}/iam-role-info.tftmpl", {
    role_name_map          = local.role_name_map
    role_name_role_arn_map = local.role_name_role_arn_map
    namespace              = module.this.namespace
  })
  filename = "${path.module}/iam-role-info/${module.this.id}.sh"
}
