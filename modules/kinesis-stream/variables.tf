variable "region" {
  type        = string
  description = "AWS Region"
}

variable "shard_count" {
  description = "The number of shards to provision for the stream."
  type        = number
  default     = 1
}

variable "retention_period" {
  description = "Length of time data records are accessible after they are added to the stream. The maximum value is 168 hours. Minimum value is 24."
  type        = number
  default     = 24
}

variable "shard_level_metrics" {
  description = "A list of shard-level CloudWatch metrics to enabled for the stream."
  type        = list(string)
  default = [
    "IncomingBytes",
    "OutgoingBytes"
  ]
}

variable "enforce_consumer_deletion" {
  description = "Forcefully delete stream consumers before destroying the stream."
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "The encryption type to use. Acceptable values are `NONE` and `KMS`."
  type        = string
  default     = "KMS"
}

variable "kms_key_id" {
  description = "The name of the KMS key to use for encryption."
  type        = string
  default     = "alias/aws/kinesis"
}

variable "stream_mode" {
  description = "Specifies the capacity mode of the stream. Must be either `PROVISIONED` or `ON_DEMAND`."
  type        = string
  default     = null
}

variable "consumer_count" {
  description = "Number of consumers to register with the Kinesis stream."
  type        = number
  default     = 0
}
