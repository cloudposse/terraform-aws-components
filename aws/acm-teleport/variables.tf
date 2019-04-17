variable "domain_name" {
  description = "Domain name for which to issue a certificate"
}

variable "chamber_service" {
  description = "`chamber` service name to use for storing the certificate ARN"
  default     = "teleport"
}

variable "chamber_parameter_name" {
  description = "Format string for combining `chamber` service name and parameter name. It is rare to need to set this."
  default     = "/%s/%s"
}

variable "certificate_arn_parameter_name" {
  description = "Chamber parameter name in which to store the AWS ARN of the issued certificate"
  default     = "teleport_ssl_certificate_arn"
}
