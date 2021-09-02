output "root_account_aws_name" {
  value       = var.root_account_aws_name
  description = "The name of the root account as reported by AWS"
}

output "root_account_stage_name" {
  value       = var.root_account_stage_name
  description = "The stage name for the root account"
}

output "identity_account_stage_name" {
  value       = var.identity_account_stage_name
  description = "The stage name for the account holding primary IAM roles"
}

output "dns_account_stage_name" {
  value       = var.dns_account_stage_name
  description = "The stage name for the primary DNS account"
}

output "artifacts_account_stage_name" {
  value       = var.artifacts_account_stage_name
  description = "The stage name for the artifacts account"
}

output "audit_account_stage_name" {
  value       = var.audit_account_stage_name
  description = "The stage name for the audit account"
}

output "org" {
  value       = data.aws_organizations_organization.organization
  description = "The name of the AWS Organization"

}

output "full_account_map" {
  value       = local.full_account_map
  description = "The map describing attributes of accounts in the AWS Organization."
}

output "eks_accounts" {
  value       = local.eks_accounts
  description = "A list of all accounts in the AWS Organization that contain EKS clusters"
}

output "non_eks_accounts" {
  value       = local.non_eks_accounts
  description = "A list of all accounts in the AWS Organization that do not contain EKS clusters"
}

output "all_accounts" {
  value       = local.all_accounts
  description = "A list of all accounts in the AWS Organization"
}

output "terraform_roles" {
  value       = local.terraform_roles
  description = "A list of all IAM roles used to run terraform updates"
}

output "terraform_profiles" {
  value       = local.terraform_profiles
  description = "A list of all SSO profiles used to run terraform updates"
}

output "helm_roles" {
  value       = local.helm_roles
  description = "A list of all IAM roles used to run helm updates"
}

output "helm_profiles" {
  value       = local.helm_profiles
  description = "A list of all SSO profiles used to run helm updates"
}

output "cicd_roles" {
  value       = local.cicd_roles
  description = "A list of all IAM roles used by cicd platforms"
}

output "cicd_profiles" {
  value       = local.cicd_profiles
  description = "A list of all SSO profiles used by cicd platforms"
}
