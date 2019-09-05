
variable "aws_assume_role_arn" {}


variable "domain_name" {
  type        = string
  description = "Domain name (E.g. staging.cloudposse.co)"
}


variable "chamber_service" {
  description = "`chamber` service name to use for storing the certificate ARN"
  default     = "kops"
}

# If certificate_arn_parameter_name is not set, no SSM parameter will be created/updated
variable "certificate_arn_parameter_name" {
  description = "Chamber parameter name in which to store the AWS ARN of the issued certificate"
  default     = ""
}

variable "chamber_parameter_name_format" {
  type        = string
  description = "Format string for combining `chamber` service name and parameter name. It is rare to need to set this."
  default     = "/%s/%s"
}

