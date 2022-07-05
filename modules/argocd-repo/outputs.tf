output "deploy_keys_ssm_paths" {
  description = "SSM Parameter Store paths for the repository's deploy keys"
  value       = module.store_write.names
}

output "deploy_keys_ssm_path_format" {
  description = "SSM Parameter Store path format for the repository's deploy keys"
  value       = local.enabled ? var.ssm_github_deploy_key_format : null
}

output "repository_description" {
  description = "Repository description"
  value       = join("", github_repository.default.*.description)
}

output "repository_default_branch" {
  description = "Repository default branch"
  value       = join("", github_repository.default.*.default_branch)
}

output "repository_url" {
  description = "Repository URL"
  value       = join("", github_repository.default.*.html_url)
}

output "repository_git_clone_url" {
  description = "Repository git clone URL"
  value       = join("", github_repository.default.*.git_clone_url)
}

output "repository_ssh_clone_url" {
  description = "Repository SSH clone URL"
  value       = join("", github_repository.default.*.ssh_clone_url)
}
