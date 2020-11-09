output "account_arns" {
  value       = local.all_account_arns
  description = "List of account ARNs"
}

output "account_ids" {
  value       = local.all_account_ids
  description = "List of account IDs"
}

output "organizational_unit_arns" {
  value       = local.organizational_unit_arns
  description = "List of Organizational Unit ARNs"
}

output "organizational_unit_ids" {
  value       = local.organizational_unit_ids
  description = "List of Organizational Unit IDs"
}

output "account_names_account_arns" {
  value       = local.account_names_account_arns
  description = "Map of account names to account ARNs"
}

output "account_names_account_ids" {
  value       = local.account_names_account_ids
  description = "Map of account names to account IDs"
}

output "organizational_unit_names_organizational_unit_arns" {
  value       = local.organizational_unit_names_organizational_unit_arns
  description = "Map of Organizational Unit names to Organizational Unit ARNs"
}

output "organizational_unit_names_organizational_unit_ids" {
  value       = local.organizational_unit_names_organizational_unit_ids
  description = "Map of Organizational Unit names to Organizational Unit IDs"
}

output "organization_id" {
  value       = aws_organizations_organization.default.id
  description = "Organization ID"
}

output "organization_arn" {
  value       = aws_organizations_organization.default.arn
  description = "Organization ARN"
}

output "organization_master_account_id" {
  value       = aws_organizations_organization.default.master_account_id
  description = "Organization master account ID"
}

output "organization_master_account_arn" {
  value       = aws_organizations_organization.default.master_account_arn
  description = "Organization master account ARN"
}

output "organization_master_account_email" {
  value       = aws_organizations_organization.default.master_account_email
  description = "Organization master account email"
}

output "eks_accounts" {
  value       = local.eks_account_names
  description = "List of EKS accounts"
}

output "non_eks_accounts" {
  value       = local.non_eks_account_names
  description = "List of non EKS accounts"
}

output "organizational_units_accounts_config" {
  value       = var.organizational_units_accounts_config
  description = "Organizational Units and Accounts configuration"
}
