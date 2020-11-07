output "account_arns" {
  value       = values(aws_organizations_account.default)[*]["arn"]
  description = "List of account ARNs"
}

output "account_ids" {
  value       = values(aws_organizations_account.default)[*]["id"]
  description = "List of account IDs"
}

output "account_names_account_arns" {
  value       = zipmap(values(aws_organizations_account.default)[*]["name"], values(aws_organizations_account.default)[*]["arn"])
  description = "Map of account names to account ARNs"
}

output "account_names_account_ids" {
  value       = zipmap(values(aws_organizations_account.default)[*]["name"], values(aws_organizations_account.default)[*]["id"])
  description = "Map of account names to account IDs"
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

output "corp_eks_accounts" {
  value = var.corp_eks_accounts
}

output "corp_non_eks_accounts" {
  value = concat(["root"], var.corp_non_eks_accounts)
}
