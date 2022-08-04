output "oidc_provider_arn" {
  description = "GitHub OIDC provider ARN"
  value       = one(values(aws_iam_openid_connect_provider.oidc)[*].arn)
}
