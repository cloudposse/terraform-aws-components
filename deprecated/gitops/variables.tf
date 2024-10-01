variable "region" {
  type        = string
  description = "AWS Region"
}

variable "s3_bucket_component_name" {
  type        = string
  description = "The name of the s3_bucket component used to store Terraform state"
  default     = "gitops/s3-bucket"
}

variable "s3_bucket_environment_name" {
  type        = string
  description = "The name of the s3_bucket environment used to store Terraform state"
  default     = null
}

variable "dynamodb_component_name" {
  type        = string
  description = "The name of the dynamodb component used to store Terraform state"
  default     = "gitops/dynamodb"
}

variable "dynamodb_environment_name" {
  type        = string
  description = "The name of the dynamodb environment used to store Terraform state"
  default     = null
}
