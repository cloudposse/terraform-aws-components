variable "aws_assume_role_arn" {
  type = "string"
}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `eg` or `cp`)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "region" {
  type        = "string"
  description = "AWS region"
}

variable "zone_name" {
  type        = "string"
  default     = ""
  description = "Domain name of DNS zone in which to add elasticsearch, optional, defaults to cluster_name"
}

variable "chamber_parameters_enabled" {
  default     = "false"
  description = "Set true to store endpoints in Chamber/SSM parameter store"
}

variable "chamber_service" {
  default     = ""
  description = "`chamber` service name shared by all services. See [chamber usage](https://github.com/segmentio/chamber#usage) for more details"
}

variable "elasticsearch_chamber_service" {
  default     = ""
  description = "`chamber` service name specific to elasticsearch"
}

variable "chamber_parameter_name" {
  default     = "/%s/%s"
  description = "Format string for converting `chamber` service and parameter names to SSM parameter name"
}

variable "cluster_name" {
  type        = "string"
  description = "Kops cluster name (e.g. `us-east-1.prod.cloudposse.co` or `cluster-1.cloudposse.co`)"
}

variable "vpc_id" {
  type        = "string"
  default     = ""
  description = "VPC ID of the Kubernetes cluster (optional, will try to auto-detect)"
}

variable "elasticsearch_name" {
  type        = "string"
  default     = "elasticsearch"
  description = "Elasticsearch cluster name"
}

variable "elasticsearch_version" {
  type        = "string"
  default     = "6.5"
  description = "Version of Elasticsearch to deploy"
}

# Encryption at rest is not supported with t2.small.elasticsearch instances
variable "elasticsearch_encrypt_at_rest_enabled" {
  type        = "string"
  default     = "false"
  description = "Whether to enable encryption at rest"
}

variable "elasticsearch_node_to_node_encryption_enabled" {
  type        = "string"
  default     = "true"
  description = "Whether to enable node-to-node encryption"
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
  default     = "true"
  description = "Set to false to prevent the module from creating any resources"
}

variable "elasticsearch_network_permitted_nodes" {
  type        = "string"
  description = "Kops kubernetes nodes that are permitted to access the elastic search network (e.g. 'nodes', 'masters', 'both' or 'any')"
  default     = "nodes"
}

variable "elasticsearch_iam_permitted_nodes" {
  type        = "string"
  description = "Kops kubernetes nodes that are permitted to use the elastic search API (e.g. 'nodes', 'masters', 'both' or 'any')"
  default     = "nodes"
}

variable "elasticsearch_iam_authorizing_role_arn" {
  type        = "string"
  description = "IAM role allowed to assume the elasticsearch user role. Typically the role that `kiam` runs as. Full ARN, or 'nodes' or 'masters')"
  default     = "masters"
}

variable "elasticsearch_log_cleanup_enabled" {
  type        = "string"
  description = "Set to \"true\" to enable automatic deletion of old logs"
  default     = "true"
}

variable "elasticsearch_log_retention_days" {
  default     = 15
  description = "Number of days of logs to retain; logs older than this many days will be deleted."
}

variable "elasticsearch_log_index_name" {
  type        = "string"
  default     = "all"
  description = "Index/indices to process. Use a comma-separated list. Specify `all` to match every index except for `.kibana` and `.kibana_1`"
}

variable "sns_arn" {
  type        = "string"
  default     = ""
  description = "SNS ARN to publish alerts"
}

variable "elasticsearch_iam_role_max_session_duration" {
  default     = 3600
  description = "The maximum session duration (in seconds) for the role. Can have a value from 1 hour to 12 hours"
}
