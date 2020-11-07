variable "elasticsearch_name" {
  type        = "string"
  default     = "elasticsearch"
  description = "Elasticsearch cluster name"
}

variable "elasticsearch_version" {
  type        = "string"
  default     = "6.2"
  description = "Version of Elasticsearch to deploy"
}

# Encryption at rest is not supported with t2.small.elasticsearch instances
variable "elasticsearch_encrypt_at_rest_enabled" {
  type        = "string"
  default     = "false"
  description = "Whether to enable encryption at rest"
}

# EBS storage must be selected for t2.small.elasticsearch
variable "elasticsearch_ebs_volume_size" {
  default     = 20
  description = "Optionally use EBS volumes for data storage by specifying volume size in GB"
}

variable "elasticsearch_instance_type" {
  type        = "string"
  default     = "t2.small.elasticsearch"
  description = "Elasticsearch instance type for data nodes in the cluster"
}

variable "elasticsearch_instance_count" {
  description = "Number of data nodes in the cluster"
  default     = 4
}

# https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-ac.html
variable "elasticsearch_iam_actions" {
  type        = "list"
  default     = ["es:ESHttpGet", "es:ESHttpPut", "es:ESHttpPost", "es:ESHttpHead", "es:Describe*", "es:List*"]
  description = "List of actions to allow for the IAM roles, _e.g._ `es:ESHttpGet`, `es:ESHttpPut`, `es:ESHttpPost`"
}

variable "elasticsearch_enabled" {
  type        = "string"
  default     = "false"
  description = "Set to false to prevent the module from creating any resources"
}

variable "elasticsearch_permitted_nodes" {
  type        = "string"
  description = "Kops kubernetes nodes that are permitted to access elastic search (e.g. 'nodes', 'masters', 'both' or 'any')"
  default     = "nodes"
}

locals {
  role_arns = {
    masters = ["${module.kops_metadata.masters_role_arn}"]
    nodes   = ["${module.kops_metadata.nodes_role_arn}"]
    both    = ["${module.kops_metadata.masters_role_arn}", "${module.kops_metadata.nodes_role_arn}"]
    any     = ["*"]
  }

  security_groups = {
    masters = ["${module.kops_metadata.masters_security_group_id}"]
    nodes   = ["${module.kops_metadata.nodes_security_group_id}"]
    both    = ["${module.kops_metadata.masters_security_group_id}", "${module.kops_metadata.nodes_security_group_id}"]
    any     = ["${module.kops_metadata.masters_security_group_id}", "${module.kops_metadata.nodes_security_group_id}"]
  }
}

module "elasticsearch" {
  source                  = "git::https://github.com/cloudposse/terraform-aws-elasticsearch.git?ref=tags/0.1.5"
  namespace               = "${var.namespace}"
  stage                   = "${var.stage}"
  name                    = "${var.elasticsearch_name}"
  dns_zone_id             = "${local.zone_id}"
  security_groups         = ["${local.security_groups[var.elasticsearch_permitted_nodes]}"]
  vpc_id                  = "${module.vpc.vpc_id}"
  subnet_ids              = ["${slice(module.subnets.private_subnet_ids, 0, min(2, length(module.subnets.private_subnet_ids)))}"]
  zone_awareness_enabled  = "${length(module.subnets.private_subnet_ids) > 1 ? "true" : "false"}"
  elasticsearch_version   = "${var.elasticsearch_version}"
  instance_type           = "${var.elasticsearch_instance_type}"
  instance_count          = "${var.elasticsearch_instance_count}"
  iam_role_arns           = ["${local.role_arns[var.elasticsearch_permitted_nodes]}"]
  iam_actions             = ["${var.elasticsearch_iam_actions}"]
  kibana_subdomain_name   = "kibana-elasticsearch"
  ebs_volume_size         = "${var.elasticsearch_ebs_volume_size}"
  encrypt_at_rest_enabled = "${var.elasticsearch_encrypt_at_rest_enabled}"
  enabled                 = "${var.elasticsearch_enabled}"

  advanced_options = {
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
