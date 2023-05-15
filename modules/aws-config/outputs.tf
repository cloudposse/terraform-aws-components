output "aws_config_iam_role" {
  description = "The ARN of the IAM Role used for AWS Config"
  value       = local.config_iam_role_arn
}
