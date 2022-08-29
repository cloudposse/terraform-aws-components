variable "visibility_timeout_seconds" {
  type        = number
  description = "The visibility timeout for the queue. An integer from 0 to 43200 (12 hours). The default for this attribute is 30. For more information about visibility timeout, see AWS docs."
  default     = 30
  validation {
    condition = (
      var.visibility_timeout_seconds >= 0 && var.visibility_timeout_seconds <= 43200
    )
    error_message = "Var must be between 0 and 43200."
  }
}

variable "message_retention_seconds" {
  type        = number
  description = "The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days). The default for this attribute is 345600 (4 days)."
  default     = 345600
  validation {
    condition = (
      var.message_retention_seconds >= 60 && var.message_retention_seconds <= 1209600
    )
    error_message = "Var must be between 60 and 1209600."
  }
}

variable "max_message_size" {
  type        = number
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it. An integer from 1024 bytes (1 KiB) up to 262144 bytes (256 KiB). The default for this attribute is 262144 (256 KiB)."
  default     = 262144
  validation {
    condition = (
      var.max_message_size >= 1024 && var.max_message_size <= 262144
    )
    error_message = "Var must be between 1024 and 262144."
  }
}

variable "delay_seconds" {
  type        = number
  description = "The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes). The default for this attribute is 0 seconds."
  default     = 0
  validation {
    condition = (
      var.delay_seconds >= 0 && var.delay_seconds <= 900
    )
    error_message = "Var must be between 0 and 900."
  }
}

variable "receive_wait_time_seconds" {
  type        = number
  description = "The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning. An integer from 0 to 20 (seconds). The default for this attribute is 0, meaning that the call will return immediately."
  default     = 0
  validation {
    condition = (
      var.receive_wait_time_seconds >= 0 && var.receive_wait_time_seconds <= 20
    )
    error_message = "Var must be between 0 and 20."
  }
}

variable "policy" {
  type        = list(string)
  description = "This is a list of 0 or 1. The JSON policy for the SQS queue. For more information about building AWS IAM policy documents with Terraform, see the [AWS IAM Policy Document Guide](https://learn.hashicorp.com/terraform/aws/iam-policy)."
  default     = []
}

variable "redrive_policy" {
  type        = list(string)
  description = "This is a list of 0 or 1. The JSON policy to set up the Dead Letter Queue, see AWS docs. Note: when specifying maxReceiveCount, you must specify it as an integer (5), and not a string (\"5\")."
  default     = []
}

variable "fifo_queue" {
  type        = bool
  description = "Boolean designating a FIFO queue. If not set, it defaults to false making it standard."
  default     = false
}

variable "fifo_throughput_limit" {
  type        = list(string)
  description = "This is a list of 0 or 1. Specifies whether the FIFO queue throughput quota applies to the entire queue or per message group. Valid values are perQueue and perMessageGroupId. This can be specified if fifo_queue is true."
  default     = []
  validation {
    condition = (
      length(var.fifo_throughput_limit) > 0 ? contains(["perQueue", "perMessageGroupId"], var.fifo_throughput_limit[0]) : true
    )
    error_message = "Var must be one of \"perQueue\", \"perMessageGroupId\"."
  }
}

variable "content_based_deduplication" {
  type        = bool
  description = "Enables content-based deduplication for FIFO queues. For more information, see the [related documentation](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/FIFO-queues.html#FIFO-queues-exactly-once-processing)"
  default     = false
}

variable "kms_master_key_id" {
  type        = list(string)
  description = "This is a list of 0 or 1. The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK. For more information, see [Key Terms](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-server-side-encryption.html#sqs-sse-key-terms)."
  default     = ["alias/aws/sqs"]
}

variable "kms_data_key_reuse_period_seconds" {
  type        = number
  description = "The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again. An integer representing seconds, between 60 seconds (1 minute) and 86,400 seconds (24 hours). The default is 300 (5 minutes)."
  default     = 300
  validation {
    condition = (
      var.kms_data_key_reuse_period_seconds >= 60 && var.kms_data_key_reuse_period_seconds <= 86400
    )
    error_message = "Var must be between 60 and 86400."
  }
}

variable "deduplication_scope" {
  type        = list(string)
  description = "This is a list of 0 or 1. Specifies whether message deduplication occurs at the message group or queue level. Valid values are messageGroup and queue. This can be specified if fifo_queue is true."
  default     = []
  validation {
    condition = (
      length(var.deduplication_scope) > 0 ? contains(["messageGroup", "queue"], var.deduplication_scope[0]) : true
    )
    error_message = "Var must be one of \"messageGroup\", \"queue\"."
  }
}
