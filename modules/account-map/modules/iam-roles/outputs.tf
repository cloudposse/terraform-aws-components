output "terraform_role_arn" {
  value = module.this.stage == data.terraform_remote_state.account_map.outputs.root_account_stage_name ? (
  "") : data.terraform_remote_state.account_map.outputs.terraform_roles[module.this.stage]
}

output "org_role_arn" {
  value = module.this.stage == data.terraform_remote_state.account_map.outputs.root_account_stage_name ? null : format(
    "arn:aws:iam::%s:role/OrganizationAccountAccessRole",
    data.terraform_remote_state.account_map.outputs.full_account_map[module.this.stage]
  )
}

output "dns_terraform_role_arn" {
  value = data.terraform_remote_state.account_map.outputs.terraform_roles[data.terraform_remote_state.account_map.outputs.dns_account_stage_name]
}

output "audit_terraform_role_arn" {
  value = data.terraform_remote_state.account_map.outputs.terraform_roles[data.terraform_remote_state.account_map.outputs.audit_account_stage_name]
}

output "identity_terraform_role_arn" {
  value = data.terraform_remote_state.account_map.outputs.terraform_roles[data.terraform_remote_state.account_map.outputs.identity_account_stage_name]
}
