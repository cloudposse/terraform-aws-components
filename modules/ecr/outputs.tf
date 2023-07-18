output "ecr_repo_arn_map" {
  value       = module.ecr.repository_arn_map
  description = "Map of image names to ARNs"
}

output "repository_host" {
  value       = try(split("/", module.ecr.repository_url)[0], null)
  description = "ECR repository name"
}

output "ecr_repo_url_map" {
  value       = module.ecr.repository_url_map
  description = "Map of image names to URLs"
}

output "ecr_user_name" {
  value       = join("", aws_iam_user.ecr.*.name)
  description = "ECR user name"
}

output "ecr_user_arn" {
  value       = join("", aws_iam_user.ecr.*.arn)
  description = "ECR user ARN"
}

output "ecr_user_unique_id" {
  value       = join("", aws_iam_user.ecr.*.unique_id)
  description = "ECR user unique ID assigned by AWS"
}
