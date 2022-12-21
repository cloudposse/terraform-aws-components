variable "region" {
  type        = string
  description = "AWS Region"
}

variable "subnet_ids" {
  description = "List of subnet IDs to use when deploying the Lambda Function in a VPC"
  type        = list(string)
  default     = null
}

variable "security_group_ids" {
  description = "List of security group IDs to use when the Lambda Function runs in a VPC"
  type        = list(string)
  default     = null
}

#https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html
variable "lambda_reserved_concurrent_executions" {
  type        = number
  description = "Amount of reserved concurrent executions for the lambda function. A value of 0 disables Lambda from being triggered and -1 removes any concurrency limitations. Defaults to Unreserved Concurrency Limits -1"
  default     = -1
}

variable "lambda_runtime" {
  type        = string
  description = "Runtime environment for Datadog Lambda"
  default     = "python3.8"
}

variable "tracing_config_mode" {
  type        = string
  description = "Can be either PassThrough or Active. If PassThrough, Lambda will only trace the request from an upstream service if it contains a tracing header with 'sampled=1'. If Active, Lambda will respect any tracing header it receives from an upstream service"
  default     = "PassThrough"
}

variable "dd_api_key_source" {
  description = "One of: ARN for AWS Secrets Manager (asm) to retrieve the Datadog (DD) api key, ARN for the KMS (kms) key used to decrypt the ciphertext_blob of the api key, or the name of the SSM (ssm) parameter used to retrieve the Datadog API key"
  type = object({
    resource   = string
    identifier = string
  })

  default = {
    resource   = ""
    identifier = ""
  }

  # Resource can be one of kms, asm, ssm ("" to disable all lambda resources)
  validation {
    condition     = can(regex("(kms|asm|ssm)", var.dd_api_key_source.resource)) || var.dd_api_key_source.resource == ""
    error_message = "Provide one, and only one, ARN for (kms, asm) or name (ssm) to retrieve or decrypt Datadog api key."
  }

  # Check KMS ARN format
  validation {
    condition     = var.dd_api_key_source.resource == "kms" ? can(regex("arn:.*:kms:.*:key/.*", var.dd_api_key_source.identifier)) : true
    error_message = "ARN for KMS key does not appear to be valid format (example: arn:aws:kms:us-west-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab)."
  }

  # Check ASM ARN format
  validation {
    condition     = var.dd_api_key_source.resource == "asm" ? can(regex("arn:.*:secretsmanager:.*:secret:.*", var.dd_api_key_source.identifier)) : true
    error_message = "ARN for AWS Secrets Manager (asm) does not appear to be valid format (example: arn:aws:secretsmanager:us-west-2:111122223333:secret:aes128-1a2b3c)."
  }

  # Check SSM name format
  validation {
    condition     = var.dd_api_key_source.resource == "ssm" ? can(regex("^[a-zA-Z0-9_./-]+$", var.dd_api_key_source.identifier)) : true
    error_message = "Name for SSM parameter does not appear to be valid format, acceptable characters are `a-zA-Z0-9_.-` and `/` to delineate hierarchies."
  }
}

variable "dd_api_key_kms_ciphertext_blob" {
  type        = string
  description = "CiphertextBlob stored in environment variable DD_KMS_API_KEY used by the lambda function, along with the KMS key, to decrypt Datadog API key"
  default     = ""
}

variable "dd_artifact_filename" {
  type        = string
  description = "The Datadog artifact filename minus extension"
  default     = "aws-dd-forwarder"
}

variable "dd_module_name" {
  type        = string
  description = "The Datadog GitHub repository name"
  default     = "datadog-serverless-functions"
}

variable "dd_forwarder_version" {
  type        = string
  description = "Version tag of Datadog lambdas to use. https://github.com/DataDog/datadog-serverless-functions/releases"
  default     = "3.61.0"
}

variable "forwarder_log_enabled" {
  type        = bool
  description = "Flag to enable or disable Datadog log forwarder"
  default     = false
}

variable "forwarder_rds_enabled" {
  type        = bool
  description = "Flag to enable or disable Datadog RDS enhanced monitoring forwarder"
  default     = false
}

variable "forwarder_vpc_logs_enabled" {
  type        = bool
  description = "Flag to enable or disable Datadog VPC flow log forwarder"
  default     = false
}

variable "forwarder_log_retention_days" {
  type        = number
  description = "Number of days to retain Datadog forwarder lambda execution logs. One of [0 1 3 5 7 14 30 60 90 120 150 180 365 400 545 731 1827 3653]"
  default     = 14
}

variable "kms_key_id" {
  type        = string
  description = "Optional KMS key ID to encrypt Datadog Lambda function logs"
  default     = null
}

variable "s3_buckets" {
  type        = list(string)
  description = "The names and ARNs of S3 buckets to forward logs to Datadog"
  default     = null
}

variable "s3_bucket_kms_arns" {
  type        = list(string)
  description = "List of KMS key ARNs for s3 bucket encryption"
  default     = []
}

variable "cloudwatch_forwarder_log_groups" {
  type        = map(map(string))
  description = <<EOT
    Map of CloudWatch Log Groups with a filter pattern that the Lambda forwarder will send logs from. For example: { mysql1 = { name = "/aws/rds/maincluster", filter_pattern = "" }
    EOT
  default     = {}
}

variable "forwarder_lambda_debug_enabled" {
  type        = bool
  description = "Whether to enable or disable debug for the Lambda forwarder"
  default     = false
}

variable "vpclogs_cloudwatch_log_group" {
  type        = string
  description = "The name of the CloudWatch Log Group for VPC flow logs"
  default     = null
}

variable "forwarder_rds_artifact_url" {
  type        = string
  description = "The URL for the code of the Datadog forwarder for RDS. It can be a local file, url or git repo"
  default     = null
}

variable "forwarder_vpc_logs_artifact_url" {
  type        = string
  description = "The URL for the code of the Datadog forwarder for VPC Logs. It can be a local file, url or git repo"
  default     = null
}

variable "forwarder_log_artifact_url" {
  type        = string
  description = "The URL for the code of the Datadog forwarder for Logs. It can be a local file, URL or git repo"
  default     = null
}

variable "lambda_policy_source_json" {
  type        = string
  description = "Additional IAM policy document that can optionally be passed and merged with the created policy document"
  default     = ""
}

variable "forwarder_log_layers" {
  type        = list(string)
  description = "List of Lambda Layer Version ARNs (maximum of 5) to attach to Datadog log forwarder lambda function"
  default     = []
}

variable "forwarder_rds_layers" {
  type        = list(string)
  description = "List of Lambda Layer Version ARNs (maximum of 5) to attach to Datadog RDS enhanced monitoring lambda function"
  default     = []
}

variable "forwarder_vpc_logs_layers" {
  type        = list(string)
  description = "List of Lambda Layer Version ARNs (maximum of 5) to attach to Datadog VPC flow log forwarder lambda function"
  default     = []
}

variable "forwarder_rds_filter_pattern" {
  type        = string
  description = "Filter pattern for Lambda forwarder RDS"
  default     = ""
}

variable "forwarder_vpclogs_filter_pattern" {
  type        = string
  description = "Filter pattern for Lambda forwarder VPC Logs"
  default     = ""
}

variable "dd_tags_map" {
  type        = map(string)
  description = "A map of Datadog tags to apply to all logs forwarded to Datadog"
  default     = {}
}

variable "context_tags_enabled" {
  type        = bool
  description = "Whether to add context tags to add to each monitor"
  default     = true
}

variable "context_tags" {
  type        = set(string)
  description = "List of context tags to add to each monitor"
  default     = ["namespace", "tenant", "environment", "stage"]
}

variable "lambda_arn_enabled" {
  type        = bool
  description = "Enable adding the Lambda Arn to this account integration"
  default     = true
}

# No Datasource for this (yet?)
/**
curl -X GET "${DD_API_URL}/api/v1/integration/aws/logs/services" \
-H "Accept: application/json" \
-H "DD-API-KEY: ${DD_API_KEY}" \
-H "DD-APPLICATION-KEY: ${DD_APP_KEY}"
**/
variable "log_collection_services" {
  type        = list(string)
  description = "List of log collection services to enable"
  default = [
    "apigw-access-logs",
    "apigw-execution-logs",
    "elbv2",
    "elb",
    "cloudfront",
    "lambda",
    "redshift",
    "s3"
  ]
}

variable "datadog_forwarder_lambda_environment_variables" {
  type        = map(string)
  default     = {}
  description = "Map of environment variables to pass to the Lambda Function"
}
