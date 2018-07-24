variable "ELASTICSEARCH_VERSION" {
  type        = "string"
  default     = "6.2"
  description = "Version of Elasticsearch to deploy"
}

variable "ELASTICSEARCH_INSTANCE_TYPE" {
  type        = "string"
  default     = "t2.small.elasticsearch"
  description = "Elasticsearch instance type for data nodes in the cluster"
}

variable "ELASTICSEARCH_INSTANCE_COUNT" {
  description = "Number of data nodes in the cluster"
  default     = 4
}

# https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-ac.html
variable "ELASTICSEARCH_IAM_ACTIONS" {
  type        = "list"
  default     = ["es:ESHttpGet", "es:ESHttpPut", "es:ESHttpPost", "es:ESHttpHead", "es:Describe*", "es:List*"]
  description = "List of actions to allow for the IAM roles, _e.g._ `es:ESHttpGet`, `es:ESHttpPut`, `es:ESHttpPost`"
}

variable "ELASTICSEARCH_ENABLED" {
  type        = "string"
  default     = "true"
  description = "Set to false to prevent the module from creating any resources"
}

module "elasticsearch" {
  source                 = "git::https://github.com/cloudposse/terraform-aws-elasticsearch.git?ref=fix-aws-security-group-rule"
  namespace              = "${var.namespace}"
  stage                  = "${var.stage}"
  name                   = "elasticsearch"
  dns_zone_id            = "${var.zone_id}"
  security_groups        = ["${module.kops_metadata.nodes_security_group_id}"]
  vpc_id                 = "${module.vpc.vpc_id}"
  subnet_ids             = ["${slice(module.subnets.public_subnet_ids, 0, max(2, length(module.subnets.public_subnet_ids)))}"]
  zone_awareness_enabled = "${length(module.subnets.public_subnet_ids) > 1 ? "true" : "false"}"
  elasticsearch_version  = "${var.ELASTICSEARCH_VERSION}"
  instance_type          = "${var.ELASTICSEARCH_INSTANCE_TYPE}"
  instance_count         = "${var.ELASTICSEARCH_INSTANCE_COUNT}"
  iam_role_arns          = ["${module.kops_metadata.nodes_role_arn}"]
  iam_actions            = ["${var.ELASTICSEARCH_IAM_ACTIONS}"]
  kibana_subdomain_name  = "kibana-elasticsearch"
  enabled                = "${var.ELASTICSEARCH_ENABLED}"

  advanced_options {
    "rest.action.multi.allow_explicit_index" = "true"
  }
}

output "elasticsearch_security_group_id" {
  value       = "${module.elasticsearch.security_group_id}"
  description = "Security Group ID to control access to the Elasticsearch domain"
}

output "elasticsearch_domain_arn" {
  value       = "${module.elasticsearch.domain_arn}"
  description = "ARN of the Elasticsearch domain"
}

output "elasticsearch_domain_id" {
  value       = "${module.elasticsearch.domain_id}"
  description = "Unique identifier for the Elasticsearch domain"
}

output "elasticsearch_domain_endpoint" {
  value       = "${module.elasticsearch.domain_endpoint}"
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
}

output "elasticsearch_kibana_endpoint" {
  value       = "${module.elasticsearch.kibana_endpoint}"
  description = "Domain-specific endpoint for Kibana without https scheme"
}

output "elasticsearch_domain_hostname" {
  value       = "${module.elasticsearch.domain_hostname}"
  description = "Elasticsearch domain hostname to submit index, search, and data upload requests"
}

output "elasticsearch_kibana_hostname" {
  value       = "${module.elasticsearch.kibana_hostname}"
  description = "Kibana hostname"
}
