variable "namespace" {
  type        = string
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  type        = string
  description = "Name to distinguish this VPC from others in this account"
  default     = "sns"
}

variable "attributes" {
  type        = list(string)
  description = "Additional attributes to distinguish this VPC from others in this account"
  default     = []
}

variable "aws_assume_role_arn" {
  type = string
}

variable "region" {
  type = string
}

variable "subscribers" {
  type = map(object({
    protocol = string
    # The protocol to use. The possible values for this are: sqs, sms, lambda, application. (http or https are partially supported, see below) (email is an option but is unsupported, see below).
    endpoint = string
    # The endpoint to send data to, the contents will vary with the protocol. (see below for more information)
    endpoint_auto_confirms = bool
    # Boolean indicating whether the end point is capable of auto confirming subscription e.g., PagerDuty (default is false)
  }))
  description = "Required configuration for subscribers to SNS topic."
  default     = {}
}

variable "monitoring_enabled" {
  type        = bool
  description = "Flag to enable CloudWatch monitoring of SNS topic."
  default     = true
}

variable "sqs_dlq_enabled" {
  type        = bool
  description = "Enable delivery of failed notifications to SQS and monitor messages in queue."
  default     = false
}
