variable "region" {
  type        = string
  description = "AWS Region"
}

// AWS KMS alias used for encryption/decryption of SSM parameters
// default is alias used in SSM
variable "kms_alias_name" {
  default = "alias/aws/ssm"
}

variable "zone_config" {
  description = "Zone config"
  type = list(object({
    subdomain = string
    zone_name = string
  }))
}
