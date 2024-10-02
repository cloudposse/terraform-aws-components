variable "region" {
  type        = string
  description = "AWS Region"
}

variable "iam_role_description" {
  type        = string
  description = "Glue IAM role description"
  default     = "Role for AWS Glue with access to EC2, S3, and Cloudwatch Logs"
}

variable "iam_policy_description" {
  type        = string
  description = "Glue IAM policy description"
  default     = "Policy for AWS Glue with access to EC2, S3, and Cloudwatch Logs"
}

variable "iam_managed_policy_arns" {
  type        = list(string)
  description = "IAM managed policy ARNs"
  default     = ["arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"]
}
