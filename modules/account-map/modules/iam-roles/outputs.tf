output "terraform_role_arn" {
  value       = module.account_map.outputs.terraform_roles[local.account_name]
  description = "The AWS Role ARN for Terraform to use when provisioning resources in the account, when Role ARNs are in use"
}

output "terraform_role_arns" {
  value       = module.account_map.outputs.terraform_roles
  description = "All of the terraform role arns"
}

output "terraform_profile_name" {
  value       = module.account_map.outputs.terraform_profiles[local.account_name]
  description = "The AWS config profile name for Terraform to use when provisioning resources in the account, when profiles are in use"
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
  description = "The AWS Role ARN for Terraform to use when SuperAdmin is provisioning resources in the account"
}

output "global_tenant_name" {
  value       = var.global_tenant_name
  description = "The `null-label` `tenant` value used for organization-wide resources"
}

output "global_environment_name" {
  value       = var.global_environment_name
  description = "The `null-label` `environment` value used for regionless (global) resources"
}

output "global_stage_name" {
  value       = var.global_stage_name
  description = "The `null-label` `stage` value for the organization management account (where the `account-map` state is stored)"
}

output "current_account_account_name" {
  value       = local.account_name
  description = <<-EOT
    The account name (usually `<tenant>-<stage>`) for the account configured by this module's inputs.
    Roughly analogous to `data "aws_caller_identity"`, but returning the name of the caller account as used in our configuration.
    EOT
}

output "dns_terraform_role_arn" {
  value       = module.account_map.outputs.terraform_roles[module.account_map.outputs.dns_account_account_name]
  description = "The AWS Role ARN for Terraform to use to provision DNS Zone delegations, when Role ARNs are in use"
}

output "dns_terraform_profile_name" {
  value       = module.account_map.outputs.terraform_profiles[module.account_map.outputs.dns_account_account_name]
  description = "The AWS config profile name for Terraform to use to provision DNS Zone delegations, when profiles are in use"
}

output "audit_terraform_role_arn" {
  value       = module.account_map.outputs.terraform_roles[module.account_map.outputs.audit_account_account_name]
  description = "The AWS Role ARN for Terraform to use to provision resources in the \"audit\" role account, when Role ARNs are in use"
}

output "audit_terraform_profile_name" {
  value       = module.account_map.outputs.terraform_profiles[module.account_map.outputs.audit_account_account_name]
  description = "The AWS config profile name for Terraform to use to provision resources in the \"audit\" role account, when profiles are in use"
}

output "identity_account_account_name" {
  value       = module.account_map.outputs.identity_account_account_name
  description = "The account name (usually `<tenant>-<stage>`) for the account holding primary IAM roles"
}

output "identity_terraform_role_arn" {
  value       = module.account_map.outputs.terraform_roles[module.account_map.outputs.identity_account_account_name]
  description = "The AWS Role ARN for Terraform to use to provision resources in the \"identity\" role account, when Role ARNs are in use"
}

output "identity_terraform_profile_name" {
  value       = module.account_map.outputs.terraform_profiles[module.account_map.outputs.identity_account_account_name]
  description = "The AWS config profile name for Terraform to use to provision resources in the \"identity\" role account, when profiles are in use"
}

output "identity_cicd_role_arn" {
  value       = module.account_map.outputs.cicd_roles[module.account_map.outputs.identity_account_account_name]
  description = "(Deprecated) The AWS Role ARN for CI/CD tools to assume to gain access to other accounts, when Role ARNs are in use"
}

output "identity_cicd_profile_name" {
  value       = module.account_map.outputs.cicd_profiles[module.account_map.outputs.identity_account_account_name]
  description = "(Deprecated) The AWS config profile name for CI/CD tools to assume to gain access to other accounts, when profiles are in use"
}

output "profiles_enabled" {
  value       = module.account_map.outputs.profiles_enabled
  description = "When true, use AWS config profiles in Terraform AWS provider configurations. When false, use Role ARNs."
}
