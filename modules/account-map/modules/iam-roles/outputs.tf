output "terraform_role_arn" {
  value = module.account_map.outputs.terraform_roles[local.account_name]
}

output "terraform_profile_name" {
  value = module.account_map.outputs.terraform_profiles[local.account_name]
}

output "aws_partition" {
  value       = module.account_map.outputs.aws_partition
  description = "The AWS \"partition\" to use when constructing resource ARNs"
}

output "org_role_arn" {
  value = local.account_name == module.account_map.outputs.root_account_account_name ? null : format(
    "arn:%s:iam::%s:role/OrganizationAccountAccessRole", module.account_map.outputs.aws_partition,
    module.account_map.outputs.full_account_map[local.account_name]
  )
}

output "global_tenant_name" {
  value       = var.global_tenant_name
  description = "The tenant name used for organization-wide resources"
}

output "global_environment_name" {
  value       = var.global_environment_name
  description = "Global environment name"
}

output "global_stage_name" {
  value       = var.global_stage_name
  description = "The stage name for the organization management account (where the `accout-map` state is stored)"
}

output "dns_terraform_role_arn" {
  value = module.account_map.outputs.terraform_roles[module.account_map.outputs.dns_account_account_name]
}

output "dns_terraform_profile_name" {
  value = module.account_map.outputs.terraform_profiles[module.account_map.outputs.dns_account_account_name]
}

output "audit_terraform_role_arn" {
  value = module.account_map.outputs.terraform_roles[module.account_map.outputs.audit_account_account_name]
}

output "audit_terraform_profile_name" {
  value = module.account_map.outputs.terraform_profiles[module.account_map.outputs.audit_account_account_name]
}

output "identity_account_account_name" {
  value       = module.account_map.outputs.identity_account_account_name
  description = "The short name for the account holding primary IAM roles"
}

output "identity_terraform_role_arn" {
  value = module.account_map.outputs.terraform_roles[module.account_map.outputs.identity_account_account_name]
}

output "identity_terraform_profile_name" {
  value = module.account_map.outputs.terraform_profiles[module.account_map.outputs.identity_account_account_name]
}

output "identity_cicd_role_arn" {
  value = module.account_map.outputs.cicd_roles[module.account_map.outputs.identity_account_account_name]
}

output "identity_cicd_profile_name" {
  value = module.account_map.outputs.cicd_profiles[module.account_map.outputs.identity_account_account_name]
}

output "profiles_enabled" {
  value = module.account_map.outputs.profiles_enabled
}
