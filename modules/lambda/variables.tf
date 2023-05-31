variable "region" {
  type        = string
  description = "AWS Region"
}

variable "function_name" {
  type        = string
  description = "Unique name for the Lambda Function."
  default     = null
}

variable "architectures" {
  type        = list(string)
  description = <<EOF
    Instruction set architecture for your Lambda function. Valid values are ["x86_64"] and ["arm64"].
    Default is ["x86_64"]. Removing this attribute, function's architecture stay the same.
  EOF
  default     = null
}

variable "cloudwatch_event_rules" {
  type        = map(any)
  description = "Creates EventBridge (CloudWatch Events) rules for invoking the Lambda Function along with the required permissions."
  default     = {}
}

variable "cloudwatch_lambda_insights_enabled" {
  type        = bool
  description = "Enable CloudWatch Lambda Insights for the Lambda Function."
  default     = false
}

variable "cloudwatch_logs_retention_in_days" {
  type        = number
  description = <<EOF
  Specifies the number of days you want to retain log events in the specified log group. Possible values are:
  1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the
  log group are always retained and never expire.
  EOF
  default     = null
}

variable "cloudwatch_logs_kms_key_arn" {
  type        = string
  description = "The ARN of the KMS Key to use when encrypting log data."
  default     = null
}

variable "cloudwatch_log_subscription_filters" {
  type        = map(any)
  description = "CloudWatch Logs subscription filter resources. Currently supports only Lambda functions as destinations."
  default     = {}
}

variable "description" {
  type        = string
  description = "Description of what the Lambda Function does."
  default     = null
}

variable "lambda_environment" {
  type = object({
    variables = map(string)
  })
  description = "Environment (e.g. ENV variables) configuration for the Lambda function enable you to dynamically pass settings to your function code and libraries."
  default     = null
}

variable "event_source_mappings" {
  type        = any
  description = <<EOF
  Creates event source mappings to allow the Lambda function to get events from Kinesis, DynamoDB and SQS. The IAM role
  of this Lambda function will be enhanced with necessary minimum permissions to get those events.
  EOF
  default     = {}
}

variable "filename" {
  type        = string
  description = "The path to the function's deployment package within the local filesystem. If defined, The s3_-prefixed options and image_uri cannot be used."
  default     = null
}

variable "ignore_external_function_updates" {
  type        = bool
  description = <<EOF
  Ignore updates to the Lambda Function executed externally to the Terraform lifecycle. Set this to `true` if you're
  using CodeDeploy, aws CLI or other external tools to update the Lambda Function code."
  EOF
  default     = false
}

variable "handler" {
  type        = string
  description = "The function entrypoint in your code."
  default     = null
}

variable "image_config" {
  type        = any
  description = <<EOF
  The Lambda OCI [image configurations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function#image_config)
  block with three (optional) arguments:
  - *entry_point* - The ENTRYPOINT for the docker image (type `list(string)`).
  - *command* - The CMD for the docker image (type `list(string)`).
  - *working_directory* - The working directory for the docker image (type `string`).
  EOF
  default     = {}
}

variable "image_uri" {
  type        = string
  description = "The ECR image URI containing the function's deployment package. Conflicts with `filename`, `s3_bucket_name`, `s3_key`, and `s3_object_version`."
  default     = null
}

variable "kms_key_arn" {
  type        = string
  description = <<EOF
  Amazon Resource Name (ARN) of the AWS Key Management Service (KMS) key that is used to encrypt environment variables.
  If this configuration is not provided when environment variables are in use, AWS Lambda uses a default service key.
  If this configuration is provided when environment variables are not in use, the AWS Lambda API does not save this
  configuration and Terraform will show a perpetual difference of adding the key. To fix the perpetual difference,
  remove this configuration.
  EOF
  default     = ""
}

variable "lambda_at_edge_enabled" {
  type        = bool
  description = "Enable Lambda@Edge for your Node.js or Python functions. The required trust relationship and publishing of function versions will be configured in this module."
  default     = false
}

variable "layers" {
  type        = list(string)
  description = "List of Lambda Layer Version ARNs (maximum of 5) to attach to the Lambda Function."
  default     = []
}

variable "memory_size" {
  type        = number
  description = "Amount of memory in MB the Lambda Function can use at runtime."
  default     = 128
}

variable "package_type" {
  type        = string
  description = "The Lambda deployment package type. Valid values are `Zip` and `Image`."
  default     = "Zip"
}

variable "permissions_boundary" {
  type        = string
  default     = ""
  description = "ARN of the policy that is used to set the permissions boundary for the role"
}

variable "publish" {
  type        = bool
  description = "Whether to publish creation/change as new Lambda Function Version."
  default     = false
}

variable "reserved_concurrent_executions" {
  type        = number
  description = "The amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations."
  default     = -1
}

variable "runtime" {
  type        = string
  description = "The runtime environment for the Lambda function you are uploading."
  default     = null
}

variable "s3_bucket_name" {
  type        = string
  description = <<EOF
  The name suffix of the S3 bucket containing the function's deployment package. Conflicts with filename and image_uri.
  This bucket must reside in the same AWS region where you are creating the Lambda function.
  EOF
  default     = null
}

variable "s3_key" {
  type        = string
  description = "The S3 key of an object containing the function's deployment package. Conflicts with filename and image_uri."
  default     = null
}

variable "s3_object_version" {
  type        = string
  description = "The object version containing the function's deployment package. Conflicts with filename and image_uri."
  default     = null
}

variable "sns_subscriptions" {
  type        = map(any)
  description = "Creates subscriptions to SNS topics which trigger the Lambda Function. Required Lambda invocation permissions will be generated."
  default     = {}
}

variable "source_code_hash" {
  type        = string
  description = <<EOF
  Used to trigger updates. Must be set to a base64-encoded SHA256 hash of the package file specified with either
  filename or s3_key. The usual way to set this is filebase64sha256('file.zip') where 'file.zip' is the local filename
  of the lambda function source archive.
  EOF
  default     = ""
}

variable "ssm_parameter_names" {
  type        = list(string)
  description = <<EOF
  List of AWS Systems Manager Parameter Store parameter names. The IAM role of this Lambda function will be enhanced
  with read permissions for those parameters. Parameters must start with a forward slash and can be encrypted with the
  default KMS key.
  EOF
  default     = null
}

variable "timeout" {
  type        = number
  description = "The amount of time the Lambda Function has to run in seconds."
  default     = 3
}

variable "tracing_config_mode" {
  type        = string
  description = "Tracing config mode of the Lambda function. Can be either PassThrough or Active."
  default     = null
}

variable "vpc_config" {
  type = object({
    security_group_ids = list(string)
    subnet_ids         = list(string)
  })
  description = <<EOF
  Provide this to allow your function to access your VPC (if both 'subnet_ids' and 'security_group_ids' are empty then
  vpc_config is considered to be empty or unset, see https://docs.aws.amazon.com/lambda/latest/dg/vpc.html for details).
  EOF
  default     = null
}

variable "custom_iam_policy_arns" {
  type        = set(string)
  description = "ARNs of custom policies to be attached to the lambda role"
  default     = []
}

variable "dead_letter_config_target_arn" {
  type        = string
  description = <<EOF
  ARN of an SNS topic or SQS queue to notify when an invocation fails. If this option is used, the function's IAM role
  must be granted suitable access to write to the target object, which means allowing either the sns:Publish or
  sqs:SendMessage action on this ARN, depending on which service is targeted."
  EOF
  default     = null
}

variable "iam_policy_description" {
  type        = string
  description = "Description of the IAM policy for the Lambda IAM role"
  default     = "Minimum SSM read permissions for Lambda IAM Role"
}

variable "policy_json" {
  type        = string
  description = "IAM policy to attach to the Lambda IAM role."
  default     = null
}

variable "iam_policy_statements" {
  description = "Map of IAM policy statements to use in the policy."
  type        = any
  default     = {}
}

variable "zip" {
  type = object({
    enabled   = optional(bool, false)
    output    = optional(string, "output.zip")
    input_dir = optional(string, null)
  })
  description = "Zip Configuration for local file deployments"
  default     = {}
}
