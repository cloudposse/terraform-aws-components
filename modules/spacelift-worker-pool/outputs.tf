output "worker_pool_id" {
  value = spacelift_worker_pool.primary.id
}

output "worker_pool_name" {
  value = spacelift_worker_pool.primary.name
}

output "spacelift_role_policy_id" {
  value = aws_iam_role_policy.spacelift_role_policy.id
}

output "spacelift_role_policy_name" {
  value = aws_iam_role_policy.spacelift_role_policy.name
}
