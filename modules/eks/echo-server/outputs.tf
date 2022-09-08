output "metadata" {
  value       = helm_release.this.*.metadata
  description = "Block status of the deployed release"
}
