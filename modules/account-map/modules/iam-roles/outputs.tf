output "terraform_role_arn" {
  value = module.account_map.outputs.terraform_roles[module.forced.stage]
}

output "terraform_profile_name" {
  value = module.account_map.outputs.terraform_profiles[module.forced.stage]
}

output "org_role_arn" {
  value = module.forced.stage == module.account_map.outputs.root_account_stage_name ? null : format(
    "arn:aws:iam::%s:role/OrganizationAccountAccessRole",
    module.account_map.outputs.full_account_map[module.forced.stage]
  )
}

output "dns_terraform_role_arn" {
  value = module.account_map.outputs.terraform_roles[module.account_map.outputs.dns_account_stage_name]
}

output "dns_terraform_profile_name" {
  value = module.account_map.outputs.terraform_profiles[module.account_map.outputs.dns_account_stage_name]
}

output "audit_terraform_role_arn" {
  value = module.account_map.outputs.terraform_roles[module.account_map.outputs.audit_account_stage_name]
}

output "audit_terraform_profile_name" {
  value = module.account_map.outputs.terraform_profiles[module.account_map.outputs.audit_account_stage_name]
}

output "identity_terraform_role_arn" {
  value = module.account_map.outputs.terraform_roles[module.account_map.outputs.identity_account_stage_name]
}

output "identity_terraform_profile_name" {
  value = module.account_map.outputs.terraform_profiles[module.account_map.outputs.identity_account_stage_name]
}

output "identity_cicd_role_arn" {
  value = module.account_map.outputs.cicd_roles[module.account_map.outputs.identity_account_stage_name]
}

output "identity_cicd_profile_name" {
  value = module.account_map.outputs.cicd_profiles[module.account_map.outputs.identity_account_stage_name]
}
