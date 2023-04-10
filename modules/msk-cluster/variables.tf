variable "region" {
  type        = string
  description = "AWS Region."
}

variable "number_of_broker_nodes" {
  type        = number
  description = "The desired total number of broker nodes in the kafka cluster. It must be a multiple of the number of specified client subnets."
}

variable "kafka_version" {
  type        = string
  description = "The desired Kafka software version"
}

variable "broker_instance_type" {
  type        = string
  description = "The instance type to use for the Kafka brokers"
}

variable "broker_volume_size" {
  type        = number
  default     = 1000
  description = "The size in GiB of the EBS volume for the data drive on each broker node"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to connect to the cluster"
}

variable "client_broker" {
  type        = string
  default     = "TLS"
  description = "Encryption setting for data in transit between clients and brokers. Valid values: `TLS`, `TLS_PLAINTEXT`, and `PLAINTEXT`"
}

variable "encryption_in_cluster" {
  type        = bool
  default     = true
  description = "Whether data communication among broker nodes is encrypted"
}

variable "encryption_at_rest_kms_key_arn" {
  type        = string
  default     = ""
  description = "You may specify a KMS key short ID or ARN (it will always output an ARN) to use for encrypting your data at rest"
}

variable "enhanced_monitoring" {
  type        = string
  default     = "DEFAULT"
  description = "Specify the desired enhanced MSK CloudWatch monitoring level. Valid values: `DEFAULT`, `PER_BROKER`, and `PER_TOPIC_PER_BROKER`"
}

variable "certificate_authority_arns" {
  type        = list(string)
  default     = []
  description = "List of ACM Certificate Authority Amazon Resource Names (ARNs) to be used for TLS client authentication"
}

variable "client_sasl_scram_enabled" {
  type        = bool
  default     = false
  description = "Enables SCRAM client authentication via AWS Secrets Manager."
}

variable "client_sasl_scram_secret_association_arns" {
  type        = list(string)
  default     = []
  description = "List of AWS Secrets Manager secret ARNs for scram authentication."
}

variable "client_sasl_iam_enabled" {
  type        = bool
  default     = false
  description = "Enables client authentication via IAM policies"
}

variable "client_tls_auth_enabled" {
  type        = bool
  default     = false
  description = "Set `true` to enable the Client TLS Authentication"
}

variable "jmx_exporter_enabled" {
  type        = bool
  default     = false
  description = "Set `true` to enable the JMX Exporter"
}

variable "node_exporter_enabled" {
  type        = bool
  default     = false
  description = "Set `true` to enable the Node Exporter"
}

variable "cloudwatch_logs_enabled" {
  type        = bool
  default     = false
  description = <<-EOT
  Indicates whether you want to enable or disable streaming broker logs to Cloudwatch Logs.

  If set to `true`, a CloudWatch Logs group will be created with `module.this.id` as the name.
  EOT
}

variable "cloudwatch_logs_retention_in_days" {
  description = <<-EOT
  Number of days you want to retain log events in the log group.

  Must be one of: [0 1 3 5 7 14 30 60 90 120 150 180 365 400 545 731 1827 3653]

  Ignored if `var.cloudwatch_logs_enabled` is set to `false`.
  EOT
  default     = "90"
}

variable "firehose_logs_enabled" {
  type        = bool
  default     = false
  description = "Indicates whether you want to enable or disable streaming broker logs to Kinesis Data Firehose"
}

variable "firehose_delivery_stream" {
  type        = string
  default     = ""
  description = "Name of the Kinesis Data Firehose delivery stream to deliver logs to"
}

variable "s3_logs_enabled" {
  type        = bool
  default     = false
  description = " Indicates whether you want to enable or disable streaming broker logs to S3"
}

variable "s3_logs_bucket" {
  type        = string
  default     = ""
  description = "Name of the S3 bucket to deliver logs to"
}

variable "s3_logs_prefix" {
  type        = string
  default     = ""
  description = "Prefix to append to the S3 folder name logs are delivered to"
}

variable "properties" {
  type        = map(string)
  default     = {}
  description = "Contents of the server.properties file. Supported properties are documented in the [MSK Developer Guide](https://docs.aws.amazon.com/msk/latest/developerguide/msk-configuration-properties.html)"
}

variable "storage_autoscaling_target_value" {
  type        = number
  default     = 60
  description = "Percentage of storage used to trigger autoscaled storage increase"
}

variable "storage_autoscaling_max_capacity" {
  type        = number
  default     = null
  description = "Maximum size the autoscaling policy can scale storage. Defaults to `broker_volume_size`"
}

variable "storage_autoscaling_disable_scale_in" {
  type        = bool
  default     = false
  description = "If the value is true, scale in is disabled and the target tracking policy won't remove capacity from the scalable resource."
}

variable "eks_security_group_ingress_enabled" {
  type        = bool
  description = "Whether to add the Security Group managed by the EKS cluster in the same regional stack to the ingress allowlist of the MSK cluster."
  default     = true
}

variable "allow_ingress_from_vpc_stages" {
  type        = list(string)
  default     = ["auto", "corp"]
  description = "List of stages to pull VPC ingress cidr and add to security group"
}

variable "vpc_ingress_tenant_name" {
  type        = string
  description = "The name of the tenant where the ingress VPC accounts are provisioned"
  default     = null
}