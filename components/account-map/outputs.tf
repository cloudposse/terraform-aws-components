output "root_account_aws_name" {
  value = var.root_account_aws_name
}

output "root_account_stage_name" {
  value = var.root_account_stage_name
}

output "identity_account_stage_name" {
  value = var.identity_account_stage_name
}

output "dns_account_stage_name" {
  value = var.dns_account_stage_name
}

output "audit_account_stage_name" {
  value = var.audit_account_stage_name
}

output "org" {
  value = data.aws_organizations_organization.organization
}

output "full_account_map" {
  value = local.full_account_map
}

output "eks_accounts" {
  value = local.eks_accounts
}

output "non_eks_accounts" {
  value = local.non_eks_accounts
}

output "all_accounts" {
  value = local.all_accounts
}

output "terraform_roles" {
  value = local.terraform_roles
}
