variable "region" {
  type        = string
  description = "AWS Region"
}

variable "cluster_attributes" {
  type        = list(string)
  description = "The attributes of the cluster name e.g. if the full name is `namespace-tenant-environment-dev-ecs-b2b` then the `cluster_name` is `ecs` and this value should be `b2b`."
  default     = []
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
  default     = "ecs"
}

variable "cluster_full_name" {
  type        = string
  description = "The fully qualified name of the cluster. This will override the `cluster_suffix`."
  default     = ""
}

variable "logs" {
  type        = any
  description = "Feed inputs into cloudwatch logs module"
  default     = {}
}

variable "containers" {
  type        = any
  description = "Feed inputs into container definition module"
  default     = {}
}

variable "task" {
  type        = any
  description = "Feed inputs into ecs_alb_service_task module"
  default     = {}
}

variable "task_policy_arns" {
  type        = list(string)
  description = "The IAM policy ARNs to attach to the ECS task IAM role"
  default = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
  ]
}

variable "domain_name" {
  type        = string
  description = "The domain name to use as the host header suffix"
  default     = ""
}

variable "public_lb_enabled" {
  type        = bool
  description = "Whether or not to use public LB and public subnets"
  default     = false
}

variable "task_enabled" {
  type        = bool
  description = "Whether or not to use the ECS task module"
  default     = true
}

variable "ecr_stage_name" {
  type        = string
  description = "The ecr stage (account) name to use for the fully qualified ECR image URL."
  default     = "auto"
}

variable "ecr_region" {
  type        = string
  description = "The region to use for the fully qualified ECR image URL. Defaults to the current region."
  default     = ""
}

variable "account_stage" {
  type        = string
  description = "The ecr stage (account) name to use for the fully qualified stage parameter store."
  default     = "auto"
}

variable "iam_policy_statements" {
  type        = any
  description = "Map of IAM policy statements to use in the policy. This can be used with or instead of the `var.iam_source_json_url`."
  default     = {}
}

variable "iam_policy_enabled" {
  type        = bool
  description = "If set to true will create IAM policy in AWS"
  default     = false
}

variable "vanity_alias" {
  type        = list(string)
  description = "The vanity aliases to use for the public LB."
  default     = []
}

variable "kinesis_enabled" {
  type        = bool
  description = "Enable Kinesis"
  default     = false
}

variable "shard_count" {
  description = "Number of shards that the stream will use"
  default     = "1"
}

variable "retention_period" {
  description = "Length of time data records are accessible after they are added to the stream"
  default     = "48"
}

variable "shard_level_metrics" {
  description = "List of shard-level CloudWatch metrics which can be enabled for the stream"

  default = [
    "IncomingBytes",
    "IncomingRecords",
    "IteratorAgeMilliseconds",
    "OutgoingBytes",
    "OutgoingRecords",
    "ReadProvisionedThroughputExceeded",
    "WriteProvisionedThroughputExceeded",
  ]
}

variable "kms_key_alias" {
  description = "ID of KMS key"
  default     = "default"
}

variable "use_lb" {
  description = "Whether use load balancer for the service"
  default     = false
  type        = bool
}

variable "stream_mode" {
  description = "Stream mode details for the Kinesis stream"
  default     = "PROVISIONED"
  type        = string
}

variable "use_rds_client_sg" {
  type        = bool
  description = "Use the RDS client security group"
  default     = false
}

variable "ecs_service_enabled" {
  default     = true
  type        = bool
  description = "Whether to create the ECS service"
}
