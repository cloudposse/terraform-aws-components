variable "region" {
  type        = string
  description = "AWS Region"
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = "A boolean that indicates the terraform state S3 bucket can be destroyed even if it contains objects. These objects are not recoverable."
}

variable "prevent_unencrypted_uploads" {
  type        = bool
  default     = false
  description = "Prevent uploads of unencrypted objects to S3"
}

variable "enable_server_side_encryption" {
  type        = bool
  default     = true
  description = "Enable DynamoDB and S3 server-side encryption"
}
