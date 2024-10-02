output "delegated_administrator_account_id" {
  value       = local.org_delegated_administrator_account_id
  description = "The AWS Account ID of the AWS Organization delegated administrator account"
}

output "member_account_ids" {
  value       = local.create_org_settings ? local.member_account_id_list : null
  description = "The AWS Account IDs of the member accounts"
}

output "macie_account_id" {
  value       = local.create_macie_account ? try(aws_macie2_account.this[0].id, null) : null
  description = "The ID of the Macie account created by the component"
}

output "macie_service_role_arn" {
  value       = local.create_macie_account ? try(aws_macie2_account.this[0].service_role, null) : null
  description = "The Amazon Resource Name (ARN) of the service-linked role that allows Macie to monitor and analyze data in AWS resources for the account."
}
