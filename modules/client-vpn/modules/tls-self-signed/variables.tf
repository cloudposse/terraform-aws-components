variable "organization_name" {
  type        = string
  description = "Name of organization to use in private certificate"
}

variable "ttl" {
  type        = number
  default     = 87600
  description = "For how many hours is the certificate to be valid?"
}
