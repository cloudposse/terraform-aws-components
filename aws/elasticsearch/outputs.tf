output "elasticsearch_security_group_id" {
  value       = module.elasticsearch.security_group_id
  description = "Security Group ID to control access to the Elasticsearch domain"
}

output "elasticsearch_domain_name" {
  value       = module.elasticsearch.domain_name
  description = "Name of the Elasticsearch domain"
}

output "elasticsearch_domain_arn" {
  value       = module.elasticsearch.domain_arn
  description = "ARN of the Elasticsearch domain"
}

output "elasticsearch_domain_id" {
  value       = module.elasticsearch.domain_id
  description = "Unique identifier for the Elasticsearch domain"
}

output "elasticsearch_domain_endpoint" {
  value       = module.elasticsearch.domain_endpoint
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
}

output "elasticsearch_kibana_endpoint" {
  value       = module.elasticsearch.kibana_endpoint
  description = "Domain-specific endpoint for Kibana without https scheme"
}

output "elasticsearch_domain_hostname" {
  value       = module.elasticsearch.domain_hostname
  description = "Elasticsearch domain hostname to submit index, search, and data upload requests"
}

output "elasticsearch_kibana_hostname" {
  value       = module.elasticsearch.kibana_hostname
  description = "Kibana hostname"
}

output "elasticsearch_user_iam_role_name" {
  value       = module.elasticsearch.elasticsearch_user_iam_role_name
  description = "IAM name of role for Elasticsearch users"
}

output "elasticsearch_user_iam_role_arn" {
  value       = module.elasticsearch.elasticsearch_user_iam_role_arn
  description = "IAM ARN of role for Elasticsearch users"
}
