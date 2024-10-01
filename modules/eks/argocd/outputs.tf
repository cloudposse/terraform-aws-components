output "github_webhook_value" {
  description = "The value of the GitHub webhook secret used for ArgoCD"
  sensitive   = true
  value       = local.webhook_github_secret
}
