output "domain_arn" {
  value       = "${module.elasticsearch.domain_arn}"
  description = "ARN of the Elasticsearch domain"
}

output "domain_id" {
  value       = "${module.elasticsearch.domain_id}"
  description = "Unique identifier for the Elasticsearch domain"
}

output "domain_hostname" {
  value       = "${module.elasticsearch.domain_hostname}"
  description = "Elasticsearch domain hostname to submit index, search, and data upload requests"
}
