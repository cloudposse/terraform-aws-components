output "organization_accessanalyzer_id" {
  value       = one(aws_accessanalyzer_analyzer.organization[*].id)
  description = "Organization Access Analyzer ID"
}

output "organization_unused_access_accessanalyzer_id" {
  value       = one(aws_accessanalyzer_analyzer.organization_unused_access[*].id)
  description = "Organization unused access Access Analyzer ID"
}

output "aws_organizations_delegated_administrator_id" {
  value       = one(aws_organizations_delegated_administrator.default[*].id)
  description = "AWS Organizations Delegated Administrator ID"
}

output "aws_organizations_delegated_administrator_status" {
  value       = one(aws_organizations_delegated_administrator.default[*].status)
  description = "AWS Organizations Delegated Administrator status"
}
