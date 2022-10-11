output "principals" {
  value       = local.principals
  description = "List of AWS principals corresponding to given input `role_map`"
}

output "permission_set_arn_like" {
  value       = local.permission_set_arn_like
  description = "List of Role ARN regexes suitable for IAM Condition `ArnLike` corresponding to given input `permission_set_map`"
}

output "full_account_map" {
  value       = module.account_map.outputs.full_account_map
  description = "Map of account names to account IDs"
}

output "aws_partition" {
  value       = local.aws_partition
  description = "The AWS \"partition\" to use when constructing resource ARNs"
}
