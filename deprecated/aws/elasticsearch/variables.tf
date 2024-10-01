variable "aws_assume_role_arn" {
  type = string
}

variable "namespace" {
  type        = string
  description = "Namespace (e.g. `eg` or `cp`)"
}

variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "zone_name" {
  type        = string
  default     = ""
  description = "Domain name of DNS zone in which to add elasticsearch, optional, defaults to cluster_name"
}

variable "chamber_parameters_enabled" {
  type        = bool
  default     = false
  description = "Set true to store endpoints in Chamber/SSM parameter store"
}

variable "chamber_service" {
  type        = string
  default     = ""
  description = "`chamber` service name shared by all services. See [chamber usage](https://github.com/segmentio/chamber#usage) for more details"
}

variable "elasticsearch_chamber_service" {
  type        = string
  default     = ""
  description = "`chamber` service name specific to elasticsearch"
}

variable "chamber_parameter_name" {
  type        = string
  default     = "/%s/%s"
  description = "Format string for converting `chamber` service and parameter names to SSM parameter name"
}

variable "cluster_name" {
  type        = string
  description = "Kops cluster name (e.g. `us-east-1.prod.cloudposse.co` or `cluster-1.cloudposse.co`)"
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID of the Kubernetes cluster (optional, will try to auto-detect)"
}

variable "elasticsearch_name" {
  type        = string
  default     = "elasticsearch"
  description = "Elasticsearch cluster name"
}

variable "elasticsearch_version" {
  type        = string
  default     = "6.5"
  description = "Version of Elasticsearch to deploy"
}

# Encryption at rest is not supported with t2.small.elasticsearch instances
variable "elasticsearch_encrypt_at_rest_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable encryption at rest"
}

variable "elasticsearch_node_to_node_encryption_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable node-to-node encryption"
}

# EBS storage must be selected for t2.small.elasticsearch
variable "elasticsearch_ebs_volume_size" {
  type        = number
  default     = 20
  description = "Optionally use EBS volumes for data storage by specifying volume size in GB"
}

variable "elasticsearch_instance_type" {
  type        = string
  default     = "t2.small.elasticsearch"
  description = "Elasticsearch instance type for data nodes in the cluster"
}

variable "elasticsearch_instance_count" {
  type        = number
  description = "Number of data nodes in the cluster"
  default     = 4
}

variable "availability_zone_count" {
  type        = number
  default     = 2
  description = "Number of Availability Zones for the domain to use."
}

# https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-ac.html
variable "elasticsearch_iam_actions" {
  type        = list(string)
  default     = ["es:ESHttpGet", "es:ESHttpPut", "es:ESHttpPost", "es:ESHttpHead", "es:Describe*", "es:List*"]
  description = "List of actions to allow for the IAM roles, _e.g._ `es:ESHttpGet`, `es:ESHttpPut`, `es:ESHttpPost`"
}

variable "elasticsearch_enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources"
}

variable "elasticsearch_network_permitted_nodes" {
  type        = string
  description = "Kops kubernetes nodes that are permitted to access the elastic search network (e.g. 'nodes', 'masters', 'both' or 'any')"
  default     = "nodes"
}

variable "elasticsearch_iam_permitted_nodes" {
  type        = string
  description = "Kops kubernetes nodes that are permitted to use the elastic search API (e.g. 'nodes', 'masters', 'both' or 'any')"
  default     = "nodes"
}

variable "elasticsearch_iam_authorizing_role_arn" {
  type        = string
  description = "IAM role allowed to assume the Elasticsearch user role. Typically the role that `kiam` runs as. Full ARN, or 'nodes' or 'masters')"
  default     = "masters"
}

variable "iam_role_arns" {
  type        = list(string)
  default     = []
  description = "List of additional IAM role ARNs to permit access to the Elasticsearch domain"
}

variable "elasticsearch_log_cleanup_enabled" {
  type        = bool
  description = "Set to `true` to enable automatic deletion of old logs"
  default     = true
}

variable "elasticsearch_log_retention_days" {
  type        = number
  default     = 15
  description = "Number of days of logs to retain; logs older than this many days will be deleted."
}

variable "elasticsearch_log_index_name" {
  type        = string
  default     = "all"
  description = "Index/indices to process. Use a comma-separated list. Specify `all` to match every index except for `.kibana` and `.kibana_1`"
}

variable "sns_arn" {
  type        = string
  default     = ""
  description = "SNS ARN to publish alerts"
}

variable "elasticsearch_iam_role_max_session_duration" {
  type        = number
  default     = 3600
  description = "The maximum session duration (in seconds) for the role. Can have a value from 1 hour to 12 hours"
}

variable "kibana_subdomain_name" {
  type        = string
  default     = "kibana-elasticsearch"
  description = "Kibana subdomain"
}

variable "elasticsearch_subdomain_name" {
  type        = string
  default     = ""
  description = "The name of the subdomain for Elasticsearch endpoint in the DNS zone (_e.g._ `elasticsearch`). If empty then module name will be used."
}

variable "create_iam_service_linked_role" {
  type        = bool
  default     = true
  description = "Whether to create `AWSServiceRoleForAmazonElasticsearchService` service-linked role. Set it to `false` if you already have an ElasticSearch cluster created in the AWS account and AWSServiceRoleForAmazonElasticsearchService already exists. See https://github.com/terraform-providers/terraform-provider-aws/issues/5218 for more info"
}

variable "artifact_url" {
  type        = string
  description = "URL template for the remote artifact for elasticsearch cleanup lambda"
  default     = "https://artifacts.cloudposse.com/$$${module_name}/$$${git_ref}/$$${filename}"
}

variable "elasticsearch_log_publishing_index_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether log publishing option for INDEX_SLOW_LOGS is enabled or not"
}

variable "elasticsearch_log_publishing_search_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether log publishing option for SEARCH_SLOW_LOGS is enabled or not"
}

variable "elasticsearch_log_publishing_application_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether log publishing option for ES_APPLICATION_LOGS is enabled or not"
}

variable "elasticsearch_log_publishing_index_cloudwatch_log_group_arn" {
  type        = string
  default     = ""
  description = "ARN of the CloudWatch log group to which log for INDEX_SLOW_LOGS needs to be published"
}

variable "elasticsearch_log_publishing_search_cloudwatch_log_group_arn" {
  type        = string
  default     = ""
  description = "ARN of the CloudWatch log group to which log for SEARCH_SLOW_LOGS needs to be published"
}

variable "elasticsearch_log_publishing_application_cloudwatch_log_group_arn" {
  type        = string
  default     = ""
  description = "ARN of the CloudWatch log group to which log for ES_APPLICATION_LOGS needs to be published"
}
