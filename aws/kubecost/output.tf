output "name" {
  value       = "${module.iam_role.name}"
  description = "The name of the IAM role created"
}

output "id" {
  value       = "${module.iam_role.id}"
  description = "The stable and unique string identifying the role"
}

output "arn" {
  value       = "${module.iam_role.arn}"
  description = "The Amazon Resource Name (ARN) specifying the role"
}
