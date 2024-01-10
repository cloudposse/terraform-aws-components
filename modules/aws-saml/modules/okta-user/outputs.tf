output "user_name" {
  value       = one(aws_iam_user.default[*].name)
  description = "User name"
}

output "user_arn" {
  value       = one(aws_iam_user.default[*].arn)
  description = "User ARN"
}

output "ssm_prefix" {
  value       = "AWS Key for ${one(aws_iam_user.default[*].name)} is in Systems Manager Parameter Store under ${aws_ssm_parameter.okta_user_access_key_id.name} and ${aws_ssm_parameter.okta_user_secret_access_key.name}"
  description = "Where to find the AWS API key information for the user"
}
