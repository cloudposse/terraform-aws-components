variable "region" {
  type        = string
  description = "AWS Region"
}

variable "cluster_attributes" {
  type        = list(string)
  description = "The attributes of the cluster name e.g. if the full name is `namespace-tenant-environment-dev-ecs-b2b` then the `cluster_name` is `ecs` and this value should be `b2b`."
  default     = []
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
  type        = number
  default     = 1
}

variable "retention_period" {
  description = "Length of time data records are accessible after they are added to the stream"
  type        = number
  default     = 48
}

variable "shard_level_metrics" {
  description = "List of shard-level CloudWatch metrics which can be enabled for the stream"
  type        = list(string)
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
  type        = string
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

variable "chamber_service" {
  default     = "ecs-service"
  type        = string
  description = "SSM parameter service name for use with chamber. This is used in chamber_format where /$chamber_service/$name/$container_name/$parameter would be the default."
}

variable "vanity_domain_enabled" {
  default     = false
  type        = bool
  description = "Whether to use the vanity domain alias for the service"
}

variable "alb_configuration" {
  type        = string
  description = "The configuration to use for the ALB, specifying which cluster alb configuration to use"
  default     = "default"
}

variable "health_check_path" {
  type        = string
  description = "The destination for the health check request"
  default     = "/health"
}

variable "health_check_port" {
  type        = string
  default     = "traffic-port"
  description = "The port to use to connect with the target. Valid values are either ports 1-65536, or `traffic-port`. Defaults to `traffic-port`"
}

variable "lb_catch_all" {
  type        = bool
  description = "Should this service act as catch all for all subdomain hosts of the vanity domain"
  default     = false
}

variable "stickiness_type" {
  type        = string
  default     = "lb_cookie"
  description = "The type of sticky sessions. The only current possible value is `lb_cookie`"
}

variable "stickiness_cookie_duration" {
  type        = number
  default     = 86400
  description = "The time period, in seconds, during which requests from a client should be routed to the same target. After this time period expires, the load balancer-generated cookie is considered stale. The range is 1 second to 1 week (604800 seconds). The default value is 1 day (86400 seconds)"
}

variable "stickiness_enabled" {
  type        = bool
  default     = true
  description = "Boolean to enable / disable `stickiness`. Default is `true`"
}

variable "autoscaling_enabled" {
  type        = bool
  default     = true
  description = "Should this service autoscale using SNS alarams"
}

variable "autoscaling_dimension" {
  type        = string
  description = "The dimension to use to decide to autoscale"
  default     = "cpu"

  validation {
    condition     = contains(["cpu", "memory"], var.autoscaling_dimension)
    error_message = "Allowed values for autoscaling_dimension are \"cpu\" or \"memory\"."
  }
}

variable "cpu_utilization_high_threshold" {
  type        = number
  description = "The maximum percentage of CPU utilization average"
  default     = 80
}

variable "cpu_utilization_high_evaluation_periods" {
  type        = number
  description = "Number of periods to evaluate for the alarm"
  default     = 1
}

variable "cpu_utilization_high_period" {
  type        = number
  description = "Duration in seconds to evaluate for the alarm"
  default     = 300
}

variable "cpu_utilization_high_alarm_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization High Alarm action"
  default     = []
}

variable "cpu_utilization_high_ok_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization High OK action"
  default     = []
}

variable "cpu_utilization_low_threshold" {
  type        = number
  description = "The minimum percentage of CPU utilization average"
  default     = 20
}

variable "cpu_utilization_low_evaluation_periods" {
  type        = number
  description = "Number of periods to evaluate for the alarm"
  default     = 1
}

variable "cpu_utilization_low_period" {
  type        = number
  description = "Duration in seconds to evaluate for the alarm"
  default     = 300
}

variable "cpu_utilization_low_alarm_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization Low Alarm action"
  default     = []
}

variable "cpu_utilization_low_ok_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization Low OK action"
  default     = []
}

variable "memory_utilization_high_threshold" {
  type        = number
  description = "The maximum percentage of Memory utilization average"
  default     = 80
}

variable "memory_utilization_high_evaluation_periods" {
  type        = number
  description = "Number of periods to evaluate for the alarm"
  default     = 1
}

variable "memory_utilization_high_period" {
  type        = number
  description = "Duration in seconds to evaluate for the alarm"
  default     = 300
}

variable "memory_utilization_high_alarm_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization High Alarm action"
  default     = []
}

variable "memory_utilization_high_ok_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization High OK action"
  default     = []
}

variable "memory_utilization_low_threshold" {
  type        = number
  description = "The minimum percentage of Memory utilization average"
  default     = 20
}

variable "memory_utilization_low_evaluation_periods" {
  type        = number
  description = "Number of periods to evaluate for the alarm"
  default     = 1
}

variable "memory_utilization_low_period" {
  type        = number
  description = "Duration in seconds to evaluate for the alarm"
  default     = 300
}

variable "memory_utilization_low_alarm_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization Low Alarm action"
  default     = []
}

variable "memory_utilization_low_ok_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization Low OK action"
  default     = []
}
